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
    @State private var viewModel = RootViewModel()

    var body: some View {
        Group {
            switch viewModel.gameState {
            case .characterGallery: FortniteStyleView()
            case .intro: IntroView()
            case .playing: MainGameView()
            case .puzzle: ReactorPuzzleView()
            case .won: EndView(isVictory: true, onNewGame: viewModel.restartGame)
            case .lost: EndView(isVictory: false, onNewGame: viewModel.restartGame)
            case .quit: FortniteStyleView()
            @unknown default: IntroView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
