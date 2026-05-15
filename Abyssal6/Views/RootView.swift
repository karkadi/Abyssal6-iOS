//
//  RootView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: – Root View
// ─────────────────────────────────────────────────────────────

struct RootView: View {
    @Environment(GameEngine.self) private var engine
    
    var body: some View {
        Group {
            switch engine.gameState {
            case .intro:
                IntroView()
            case .playing:
                MainGameView()
            case .puzzle:
                ReactorPuzzleView()
            case .won:
                EndView(isVictory: true, onNewGame: { engine.restartGame() })
            case .lost:
                EndView(isVictory: false, onNewGame: { engine.restartGame() })
            case .quit:
                IntroView()
            @unknown default:
                IntroView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
        .environment(GameEngine())
}
