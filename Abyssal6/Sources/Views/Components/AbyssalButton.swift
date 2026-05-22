//
//  AbyssalButton.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: – Reusable Components
// ─────────────────────────────────────────────────────────────

struct AbyssalButton: View {
    let title: String
    let color: Color
    let scaleY: CGFloat
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(AbyssalButtonStyle(color: color.opacity(0.15), accent: color, scaleY: scaleY))
            .frame(minWidth: 180, minHeight: 52)
    }
}

struct AbyssalButtonStyle: ButtonStyle {
    let color: Color
    let accent: Color
    let scaleY: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12 * scaleY, weight: .bold, design: .monospaced))
            .foregroundColor(accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? accent.opacity(0.3) : color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(accent, lineWidth: 1.5)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
