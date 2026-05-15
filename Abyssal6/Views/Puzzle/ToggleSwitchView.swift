//
//  ToggleSwitchView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

/// A custom toggle switch that displays one of two images depending on the state.
/// Tapping the view toggles the state.
struct ToggleSwitchView: View {
    /// Image name for the ON state.
    let onImageName: String
    /// Image name for the OFF state.
    let offImageName: String
    /// Binding to the current state (true = ON, false = OFF).
    @Binding var isOn: Bool
    
    /// Receives the height scaling factor from parent context
    let scaleFactor: CGFloat
    
    var body: some View {
        Image(isOn ? onImageName : offImageName)
            .resizable()
            .scaledToFit()
            // Proportional frame bounding box scaled according to global device height scale
            .frame(width: 38 * scaleFactor, height: 56 * scaleFactor)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isOn.toggle()
                }
            }
    }
}

// MARK: – Preview

#Preview {
    VStack(spacing: 20) {
        ToggleSwitchView(
            onImageName: "on",
            offImageName: "off",
            isOn: .constant(true),
            scaleFactor: 1.0
        )
        ToggleSwitchView(
            onImageName: "on",
            offImageName: "off",
            isOn: .constant(false),
            scaleFactor: 1.0
        )
    }
    .padding()
    .background(Color.abyssalBg)
}
