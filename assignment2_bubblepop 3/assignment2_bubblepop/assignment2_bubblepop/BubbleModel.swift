//
//  BubbleModel.swift
//  assignment2_bubblepop
//
//  Created by GILES CHEN on 26/4/2025.
//



import SwiftUI

enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black

    var color: Color {
        switch self {
        case .red: return .red
        case .pink: return .pink
        case .green: return .green
        case .blue: return .blue
        case .black: return .black
        }
    }
    
    var points: Int {
        switch self {
        case .red: return 1
        case .pink: return 2
        case .green: return 5
        case .blue: return 8
        case .black: return 10
        }
    }
}

struct Bubble: Identifiable {
    let id = UUID()
    let colorType: BubbleColor
    var position: CGPoint

    static let bubbleSize: CGFloat = 60
    static let minDistance: CGFloat = bubbleSize + 10
    static let maxAttempts = 1000
    static let minBubbleCount = 5
    static let maxBubbleCount = 15
    static let refreshInterval: TimeInterval = 1.0

    static var radius: CGFloat { bubbleSize / 2 }
    var velocity: CGVector
    
}

