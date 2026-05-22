//
//  FadeTransitionModifier.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

/// A modifier that adds a fade‑in / fade‑out transition to a view.
struct FadeTransitionModifier: ViewModifier {
    let isActive: Bool
    let duration: Double

    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .animation(.easeInOut(duration: duration), value: isActive)
    }
}

extension View {
    /// Applies a fade transition that animates the view's opacity when `isActive` changes.
    func fadeTransition(isActive: Bool, duration: Double = 0.3) -> some View {
        modifier(FadeTransitionModifier(isActive: isActive, duration: duration))
    }
}
