//
//  StartGameView.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 23/4/2025.
//

import SwiftUI

struct StartGameView: View {
    @StateObject var gameController: GameController
    @StateObject var highScoreVM = HighScoreViewModel()
    @Binding var path: NavigationPath
    let playerName: String
    let gameTime: Int
    let maxBubbles: Int

    init(path: Binding<NavigationPath>, playerName: String, gameTime: Int, maxBubbles: Int) {
            _gameController = StateObject(wrappedValue: GameController(playerName: playerName, gameTime: gameTime, maxBubbles: maxBubbles))
            self._path = path
            self.playerName = playerName
            self.gameTime = gameTime 
            self.maxBubbles = maxBubbles
        }
    
    var body: some View {
        GeometryReader { geo in
            let gameAreaWidth: CGFloat = max(geo.size.width - 40, 100)
            let gameAreaHeight: CGFloat = max(geo.size.height - 200, 100)
            

            VStack {
                // 1. 顶部 HUD（玩家、时间、分数）
                HStack {
                    Text("Player: \(playerName)")
                    Spacer()
                    Text("Time: \(gameController.timeRemaining)")
                    Spacer()
                    Text("Score: \(gameController.score)")
                }
                .padding()

                Spacer()
                    .onAppear {
                        print("📐 geo.size: \(geo.size)")
                        gameController.highScoreVM = highScoreVM
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // 👈 延迟一帧执行
                                gameController.startGame( gameAreaWidth: gameAreaWidth, gameAreaHeight: gameAreaHeight)
                            }
                    }
                    

                // 2. 泡泡区域（黑框 + 泡泡）
                ZStack {
                    // 黑框
                    Rectangle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: gameAreaWidth, height: gameAreaHeight)

                    // 泡泡
                    ForEach(gameController.bubbles) { bubble in
                        Circle()
                            .fill(bubble.colorType.color)
                            .frame(width: Bubble.bubbleSize, height: Bubble.bubbleSize)
                            .position(x: bubble.position.x, y: bubble.position.y)
                            .onTapGesture {
                                gameController.popBubble(bubble)
                            }
                    }
                }
                .frame(width: gameAreaWidth, height: gameAreaHeight)  // 👈 固定泡泡区大小
            }
        }
            .onDisappear {
                gameController.bubbles.removeAll()
            }
            
            .fullScreenCover(isPresented: $gameController.isGameOver) {
                HighScoreView(viewModel: gameController.highScoreVM ?? HighScoreViewModel(), path: $path)
            }
        }
    }


#Preview {
    StartGameView(
        path: .constant(NavigationPath()),
        playerName: "Test",
        gameTime: 50,        // 👈 加上游戏时间
        maxBubbles: 10       // 👈 加上最大泡泡数
    )
}

