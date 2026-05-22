//
//  CharacterCalloutView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 20/05/2026.
//

import SwiftUI

struct CharacterCalloutView: View {
    let character: StaticCharacter
    let onDismiss: () -> Void

    @State private var opacity: Double = 0.0

    var body: some View {
        VStack(spacing: 12) {
            Text(character.localizedName)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.abyssalAccent)

            Text(character.fullDescription)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.abyssalText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(Lang.string("talk_hint"))
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.abyssalDim)
        }
        .padding()
        .background(Color.abyssalPanel.opacity(0.95))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.abyssalAccent, lineWidth: 2)
        )
        .padding(40)
        .opacity(opacity)
        .task {
            // 1. Show typewriter after 0.5 seconds
            do {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1.0
                }
                // Auto‑dismiss after 3 seconds
                try await Task.sleep(for: .seconds(3.0))
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0.0
                }
                try await Task.sleep(for: .seconds(0.3))
                onDismiss()

            } catch {
                // Handles cancellation gracefully if the user skips or leaves the view
            }
        }
    }
}
