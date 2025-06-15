//
//  ContentView.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 23/4/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()  // 👈 新增：导航路径控制

    var body: some View {
        NavigationStack(path: $path) {   // 👈 改成 NavigationStack
            VStack {
                Label("Bubble Pop", systemImage: "")
                    .foregroundStyle(.mint)
                    .font(.largeTitle)
                
                Spacer()
                
                NavigationLink("New Game", value: "settings")  // 👈 直接传值
                    .font(.title)
                    .padding(50)
                
                NavigationLink("High Score", value: "highscore")
                    .font(.title)
                
                Spacer()
            }
            .navigationDestination(for: String.self) { route in
                if route == "settings" {
                    SettingView(path: $path)  // 👈 传 path 给 SettingView
                } else if route == "highscore" {
                    HighScoreView(viewModel: HighScoreViewModel(), path: $path)
                }
            }
        }
    }
}

        
#Preview {
    ContentView()
}
