//
//  HighScoreView.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 23/4/2025.
//

import SwiftUI

struct HighScoreView: View {
    @ObservedObject var viewModel: HighScoreViewModel  // 👈 传入排行榜 ViewModel
    @Binding var path: NavigationPath                  // 👈 用来返回菜单

    var body: some View {
        VStack {
            Label("High Score", systemImage: "")
                .foregroundStyle(.red)
                .font(.title)
            
            Spacer()
            
            // 展示排行榜
            List(viewModel.scores) { entry in
                Text("\(entry.name) - \(entry.score)")
            }

            
            Spacer()
            
            Button("Back to Menu") {
                path.removeLast(path.count)  // 👈 清空导航栈，回主菜单
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .onAppear {
            viewModel.loadHighScores()  // 👈 进入页面时，加载排行榜数据
        }
    }
}

#Preview {
    HighScoreView(viewModel: HighScoreViewModel(), path: .constant(NavigationPath()))

}
