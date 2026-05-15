//
//  EasterEggView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

/// A modal view that displays a secret image (easter egg) with a fading effect.
/// The image’s visibility depends on the torch’s battery level, which decreases over time.
struct EasterEggView: View {
    let torch: Torch
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var batteryLevel: Int
    @State private var imageOpacity: Double = 0.0
    @State private var fadeOut = false

    private let dischargeInterval: TimeInterval = 0.5   // discharge every 0.5 sec
    private let dischargeAmount = 2                    // % per interval

    init(torch: Torch, onDismiss: @escaping () -> Void = {}) {
        self.torch = torch
        self.onDismiss = onDismiss
        _batteryLevel = State(initialValue: torch.batteryLife)
    }

    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap anywhere closes (like Java)
                    close()
                }

            VStack(spacing: 20) {
                // Battery info panel
                VStack(spacing: 8) {
                    Text(Lang.string("easter_egg_title"))
                        .font(.title2.bold())
                        .foregroundColor(.abyssalAccent)

                    batteryLabel
                    batteryProgressBar
                }
                .padding()
                .background(Color.abyssalPanel.opacity(0.8))
                .cornerRadius(16)

                // Secret image (fade in/out + battery‑dependent opacity)
                Image("millman")   // Ensure millman.jpg is in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 500, maxHeight: 400)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .opacity(imageOpacity * batteryVisibilityFactor)
                    .overlay(
                        Group {
                            if batteryLevel <= 0 {
                                Color.black.opacity(0.7)
                                Text(Lang.string("easter_egg_torch_depleted"))
                                    .foregroundColor(.red)
                                    .font(.headline)
                            }
                        }
                    )

                // Close button
                AbyssalButton(title: Lang.string("close"), color: .abyssalAccent) {
                    close()
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .onAppear {
            startFadeIn()
            startBatteryDischarge()
        }
        .interactiveDismissDisabled(true)   // must close via button or tap
    }

    // MARK: - Subviews

    private var batteryLabel: some View {
        let color: Color
        let text: String

        if batteryLevel >= 70 {
            color = .green
            text = String(format: Lang.string("easter_egg_battery_powerful"), batteryLevel)
        } else if batteryLevel >= 40 {
            color = .yellow
            text = String(format: Lang.string("easter_egg_battery_moderate"), batteryLevel)
        } else if batteryLevel >= 15 {
            color = .orange
            text = String(format: Lang.string("easter_egg_battery_low"), batteryLevel)
        } else {
            color = .red
            text = String(format: Lang.string("easter_egg_battery_critical"), batteryLevel)
        }

        return Text(text)
            .font(.system(.body, design: .monospaced))
            .foregroundColor(color)
    }

    private var batteryProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .cornerRadius(10)

                Rectangle()
                    .fill(batteryLevel >= 70 ? .green : (batteryLevel >= 40 ? .yellow : (batteryLevel >= 15 ? .orange : .red)))
                    .frame(width: max(0, geometry.size.width * CGFloat(batteryLevel) / 100), height: 20)
                    .cornerRadius(10)
            }
        }
        .frame(height: 20)
        .padding(.horizontal, 40)
    }

    private var batteryVisibilityFactor: Double {
        // visibility = batteryLevel / 100, min 0.01 (Java logic)
        return max(0.01, Double(batteryLevel) / 100.0)
    }

    // MARK: - Animations

    private func startFadeIn() {
        withAnimation(.easeIn(duration: 0.5)) {
            imageOpacity = 1.0
        }
    }

    private func startBatteryDischarge() {
        Timer.scheduledTimer(withTimeInterval: dischargeInterval, repeats: true) { timer in
            guard batteryLevel > 0 else {
                timer.invalidate()
                return
            }
            let newLevel = max(0, batteryLevel - dischargeAmount)
            batteryLevel = newLevel
            torch.setBatteryLife(newLevel)   // update the actual torch object

            if batteryLevel <= 0 {
                timer.invalidate()
                // Fade out image
                withAnimation(.easeOut(duration: 0.5)) {
                    imageOpacity = 0.0
                }
            }
        }
    }

    private func close() {
        withAnimation(.easeOut(duration: 0.3)) {
            imageOpacity = 0.0
        }
        Task { @MainActor in
            // Descriptive duration API
            try? await Task.sleep(for: .seconds(0.3))
            
            dismiss()
            onDismiss()
        }
        
    }
}

// MARK: - Preview

#Preview {
    let torch = Torch(type: ItemType.torch)
    torch.setBatteryLife(85)
    return EasterEggView(torch: torch)
}
