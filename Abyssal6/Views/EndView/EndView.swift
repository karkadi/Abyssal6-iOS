//
//  EndView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

/// The end game screen shown after victory or game over.
struct EndView: View {
    let isVictory: Bool
    let onNewGame: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    private let remoteImageBaseURL = "https://kazazyanalexander.github.io/Abyssale-6/images/"
    var body: some View {
        ZStack {
            // Background
            Color.abyssalBg
                .ignoresSafeArea()
            
            // Optional background image for victory/loss
            GIFImage(source: "\(remoteImageBaseURL)\(isVictory ? "win.gif" : "lost.gif")")
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Title and message
                VStack(spacing: 16) {
                    Image(systemName: isVictory ? "trophy.fill" : "skull")
                        .font(.system(size: 64))
                        .foregroundColor(isVictory ? .yellow : .red)
                    
                    Text(isVictory ? Lang.string("victory_title") : Lang.string("game_over_title"))
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(isVictory ? .abyssalAccent : .abyssalDanger)
                    
                    Text(isVictory ? Lang.string("victory_message") : Lang.string("game_over_confirm"))
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.abyssalText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 20) {
                    AbyssalButton(title: Lang.string("new_game"), color: .abyssalSuccess) {
                        onNewGame()
                        dismiss()
                    }
                    .frame(width: 200)
                    
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(true)   // prevent swipe to dismiss
    }
}

// MARK: - Preview

#Preview("Victory") {
    EndView(isVictory: true, onNewGame: {})
}

#Preview("Game Over") {
    EndView(isVictory: false, onNewGame: {})
}
