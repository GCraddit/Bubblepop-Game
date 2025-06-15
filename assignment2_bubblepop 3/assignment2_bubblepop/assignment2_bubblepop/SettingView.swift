//
//  SettingView.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 23/4/2025.
//

import SwiftUI

struct SettingView: View {
    @StateObject var highScoreViewModel = HighScoreViewModel()
    @State private var countdownInput = ""
    @State private var countdownValue: Double = 0
    @State private var numberOfBubbles: Double = 0
    @State private var playerName: String = ""
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack{
            Label("Setting", systemImage: "")
                .foregroundStyle(.green)
                .font(.title)
            Spacer()
            
            Text("Enter You Name: ")
            TextField("Enter Name", text: $playerName)
                .padding()
            Spacer()
            
            Text("Game Time")
            Slider(value: $countdownValue, in: 10...60, step: 1)
                .padding()
                .onChange(of: countdownValue, perform: {value in countdownInput = "\(Int(value))"
                })
            Text("\(Int(countdownValue))")
                .padding()
            
            Text("Max Number of Bubbles")
            Slider(value: $numberOfBubbles, in: 5...15, step: 1)
                .padding()
            Text("\(Int(numberOfBubbles))")
                .padding()
            
            
            NavigationLink(
                destination: StartGameView(
                    path: $path,
                            playerName: playerName,
                            gameTime: Int(countdownValue),
                            maxBubbles: Int(numberOfBubbles)
                ),
                label: {
                    Text("Start Game")
                        .font(.title)
                })
            .disabled(playerName.isEmpty)
            .opacity(playerName.isEmpty ? 0.5:1)
            Spacer()
        }
        .padding()
        .onDisappear{
            UserDefaults.standard.set(playerName, forKey: "playerName")
            UserDefaults.standard.set(Int(countdownValue), forKey: "gameTime")
            UserDefaults.standard.set(Int(numberOfBubbles), forKey: "maxBubbles")
        }
    }
}
    #Preview {
        SettingView(path: .constant(NavigationPath()))
    }
