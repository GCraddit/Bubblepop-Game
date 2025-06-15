//
//  HighScoreViewModel.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 23/4/2025.
//


import SwiftUI

struct ScoreEntry: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let score: Int
}

class HighScoreViewModel: ObservableObject {
    @Published var scores: [ScoreEntry] = []  // 👈 用结构体代替字典

    func loadHighScores() {
        let savedScores = UserDefaults.standard.array(forKey: "highScores") as? [[String: Any]] ?? []
        scores = savedScores.compactMap { dict in
            if let name = dict["name"] as? String, let score = dict["score"] as? Int {
                return ScoreEntry(name: name, score: score)
            }
            return nil
        }
    }

    func saveNewScore(name: String, score: Int) {
        var highScores = UserDefaults.standard.array(forKey: "highScores") as? [[String: Any]] ?? []
        highScores.append(["name": name, "score": score])
        highScores.sort { ($0["score"] as? Int ?? 0) > ($1["score"] as? Int ?? 0) }
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        UserDefaults.standard.set(highScores, forKey: "highScores")
        loadHighScores()  // 👈 保存后再刷新 scores
    }
}





