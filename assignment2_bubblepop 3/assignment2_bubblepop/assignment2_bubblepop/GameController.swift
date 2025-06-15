//
//  GameController.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 26/4/2025.
//

import SwiftUI

class GameController: ObservableObject {
    var timer: Timer?
    
    @Published var bubbles: [Bubble] = []    // 当前泡泡数组
    @Published var score: Int = 0            // 当前分数
    @Published var timeRemaining: Int        // 剩余时间
    @Published var isGameOver: Bool = false  // 游戏是否结束

    let playerName: String                   // 玩家名字
    let maxBubbles: Int              // 最大泡泡数
    let gameTime: Int

    var highScoreVM: HighScoreViewModel?     // 排行榜 ViewModel（外部传）

    // 👇 初始化，读取配置
    init(playerName: String, gameTime: Int, maxBubbles: Int) {
        self.playerName = playerName
        self.gameTime = gameTime
        self.maxBubbles = maxBubbles
        self.timeRemaining = gameTime
    }

    func startGame(gameAreaWidth: CGFloat, gameAreaHeight: CGFloat) {
        print("🚀 startGame 被调用")
        score = 0                // 分数清零
        isGameOver = false       // 状态重置
        generateBubbles(gameAreaWidth: gameAreaWidth,
                        gameAreaHeight: gameAreaHeight) // 生成初始泡泡
        timer?.invalidate()  // 保险：先取消已有 Timer
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(timerFired),
                                         userInfo: ["width": gameAreaWidth, "height": gameAreaHeight],
                                         repeats: true)
    }
    
    @objc func timerFired(_ timer: Timer) {
        guard !isGameOver else { return }
        timeRemaining -= 1
        print("⏱️ timerFired，剩余时间: \(timeRemaining)")

        // 取出 userInfo 里的参数
        if let userInfo = timer.userInfo as? [String: Any],
           let width = userInfo["width"] as? CGFloat,
           let height = userInfo["height"] as? CGFloat {
            
            moveBubbles(gameAreaWidth: width, gameAreaHeight: height)  // 👈 加这个
            // generateBubbles(gameAreaWidth: width, gameAreaHeight: height)  // ⛔️ 暂时注释
        }

        if timeRemaining <= 0 {
            endGame()
        }
    }


    
    func generateBubbles(gameAreaWidth: CGFloat, gameAreaHeight: CGFloat) {
        guard gameAreaWidth > 0 && gameAreaHeight > 0 else {
                print("⚠️ 游戏区域无效，跳过 generateBubbles")
                return
            }
        print("🟢 generateBubbles 被调用")
           print("📏 区域宽: \(gameAreaWidth), 高: \(gameAreaHeight)")
        let radius = Bubble.radius
        let minDistance = Bubble.minDistance
        let maxAttempts = Bubble.maxAttempts

        // 黑框边界（以左上角为 (0,0)）
        let safeLeft = radius
        let safeRight = gameAreaWidth - radius
        let safeTop = radius
        let safeBottom = gameAreaHeight - radius

        let needed = maxBubbles - bubbles.count
        var newBubbles: [Bubble] = []

        var attempts = 0
        while newBubbles.count < needed && attempts < maxAttempts {
            attempts += 1

            let x = CGFloat.random(in: safeLeft...safeRight)
            let y = CGFloat.random(in: safeTop...safeBottom)
            let newPos = CGPoint(x: x, y: y)

            // 1. 重叠检测
            let overlap = (bubbles + newBubbles).contains { existing in
                let dx = existing.position.x - newPos.x
                let dy = existing.position.y - newPos.y
                return sqrt(dx*dx + dy*dy) < minDistance
            }
            if overlap { continue }  // 重叠跳过

            // 2. 添加泡泡
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 10...20)
            let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
            let colorType = BubbleColor.allCases.randomElement()!

            newBubbles.append(Bubble(colorType: colorType, position: newPos, velocity: velocity))
        }

        // 3. 合并并过滤（确保所有泡泡在黑框内）
        bubbles += newBubbles
        bubbles = bubbles.filter { bubble in
            bubble.position.x >= safeLeft &&
            bubble.position.x <= safeRight &&
            bubble.position.y >= safeTop &&
            bubble.position.y <= safeBottom
        }
    }

    private var lastPoppedColor: BubbleColor? = nil  // 记录上一个泡泡颜色

    func popBubble(_ bubble: Bubble) {
        // 1. 移除被点击的泡泡
        if let index = bubbles.firstIndex(where: { $0.id == bubble.id }) {
            bubbles.remove(at: index)
        }

        // 2. 计算分数
        var points = bubble.colorType.points
        if bubble.colorType == lastPoppedColor {
            points = Int(Double(points) * 1.5)  // 连击加分
        }
        score += points

        // 3. 更新上一个泡泡颜色
        lastPoppedColor = bubble.colorType
    }
    
    func moveBubbles(gameAreaWidth: CGFloat, gameAreaHeight: CGFloat) {
        print("🔵 moveBubbles 被调用")
            
            for bubble in bubbles {
                print("➡️ 泡泡ID: \(bubble.id), 位置: \(bubble.position), 速度: \(bubble.velocity)")
            }
        
        let acceleration: CGFloat = 1.03
        let maxSpeed: CGFloat = 50.0

        for i in (0..<bubbles.count).reversed() {
            var bubble = bubbles[i]

            // 1. 计算下一帧位置
            let nextX = bubble.position.x + bubble.velocity.dx
            let nextY = bubble.position.y + bubble.velocity.dy

            // 2. 判断是否超出缓冲区（彻底飞出黑框才消失）
            if nextX < -Bubble.radius*3 || nextX > gameAreaWidth + Bubble.radius*3 ||
               nextY < -Bubble.radius*3 || nextY > gameAreaHeight + Bubble.radius*3 {
                bubbles.remove(at: i)
                continue
            }

            // 3. 判断是否在缓冲区边缘，强制拉回
            if nextX < Bubble.radius {
                bubble.position.x = Bubble.radius
                bubble.velocity.dx *= -1  // 反弹
            } else if nextX > gameAreaWidth - Bubble.radius {
                bubble.position.x = gameAreaWidth - Bubble.radius
                bubble.velocity.dx *= -1
            } else {
                bubble.position.x = nextX  // 正常移动
            }

            if nextY < Bubble.radius {
                bubble.position.y = Bubble.radius
                bubble.velocity.dy *= -1
            } else if nextY > gameAreaHeight - Bubble.radius {
                bubble.position.y = gameAreaHeight - Bubble.radius
                bubble.velocity.dy *= -1
            } else {
                bubble.position.y = nextY
            }

            // 4. 加速
            bubble.velocity.dx = min(abs(bubble.velocity.dx) * acceleration, maxSpeed) * (bubble.velocity.dx < 0 ? -1 : 1)
            bubble.velocity.dy = min(abs(bubble.velocity.dy) * acceleration, maxSpeed) * (bubble.velocity.dy < 0 ? -1 : 1)

            // 5. 泡泡之间的碰撞
            for j in 0..<bubbles.count {
                if i == j { continue }  // 自己不跟自己碰撞

                let other = bubbles[j]
                let dx = bubble.position.x - other.position.x
                let dy = bubble.position.y - other.position.y
                let distance = sqrt(dx*dx + dy*dy)

                if distance < Bubble.bubbleSize && distance > 0 {
                    // 1. 简单交换速度
                    let tempVelocity = bubble.velocity
                    bubble.velocity = other.velocity
                    bubbles[j].velocity = tempVelocity

                    // 2. 轻微调整位置，防止卡住
                    let overlap = Bubble.minDistance - distance
                    let adjustX = dx / distance * (overlap / 2)
                    let adjustY = dy / distance * (overlap / 2)
                    bubble.position.x += adjustX
                    bubble.position.y += adjustY
                    bubbles[j].position.x -= adjustX
                    bubbles[j].position.y -= adjustY
                }
            }

            bubbles[i] = bubble
        }
    }
    
    func endGame() {
        print("🛑 游戏结束，分数: \(score)")
        bubbles.removeAll()  // 清空泡泡
        timer?.invalidate()
        timer = nil
        print("Game Over! Player: \(playerName), Score: \(score)")
        saveScore()          // 保存分数
        isGameOver = true    // 标记游戏结束，触发页面跳转
    }

    private func saveScore() {
        highScoreVM?.saveNewScore(name: playerName, score: score)
    }
}


