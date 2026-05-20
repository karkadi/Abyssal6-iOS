//
//  ReactorPuzzleView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

/// The main puzzle view where the player must configure 8 switches to achieve
/// a specific voltage (3.2V - 3.4V) on the voltmeter, then press the red button.
struct ReactorPuzzleView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    // MARK: - View Model
    @State private var viewModel = PuzzleViewModel()

    // Canvas reference properties matching original dimensions
    private let refWidth: CGFloat = 900
    private let refHeight: CGFloat = 680

    // Base reference layout positions
    private var baseSwitchesStartX: CGFloat {
        horizontalSizeClass == .regular ? 208.0 : 210.0
    }
    private var baseSwitchesSpacingX: CGFloat {
        horizontalSizeClass == .regular ? 54.0 : 54.0
    }
    private var baseSwitchesY: CGFloat {
        horizontalSizeClass == .regular ? 186.0 : 192.0
    }
    private var buttonX: CGFloat {
        horizontalSizeClass == .regular ? 238 : 246
    }
    private var buttonY: CGFloat {
        horizontalSizeClass == .regular ? 424 : 422
    }
    private let buttonDiameter: CGFloat = 50

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            // Calculate a single scaling factor based entirely on screen height
            let scaleY = geometry.size.height / refHeight

            // Calculate an X-offset to center your content container if the screen width
            // is aspect-ratio wider than the height-scaled content canvas
            let canvasScaledWidth = refWidth * scaleY
            let horizontalOffset = (geometry.size.width - canvasScaledWidth) / 2

            ZStack {
                // Background
                Color.abyssalBg
                    .ignoresSafeArea()

                // Voltmeter View
                VoltmeterView(voltage: viewModel.currentVoltage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .padding()

                // Text Layouts Container
                VStack(spacing: 0) {
                    // Title (Scaled dynamically based on height)
                    Text(Lang.string("puzzle_title"))
                        .font(.system(size: 28 * scaleY, weight: .bold, design: .monospaced))
                        .foregroundColor(.abyssalAccent)
                        .padding(.top, 2 * scaleY)

                    Spacer()

                    // Instruction text (Scaled dynamically based on height)
                    Text(Lang.string("puzzle"))
                        .font(.system(size: max(10, 16 * scaleY), design: .monospaced))
                        .foregroundColor(.abyssalText)
                        .multilineTextAlignment(.center)
                    // Responsively adapts padding to avoid clipping on narrow screens
                        .padding(.horizontal, max(20, 160 * scaleY))
                        .padding(.bottom, 12 * scaleY)
                }
                .ignoresSafeArea()

                // 8 Switches arranged uniformly using the height scale aspect ratios
                ForEach(0..<viewModel.switchStates.count, id: \.self) { index in
                    let rawX = baseSwitchesStartX + CGFloat(index) * baseSwitchesSpacingX
                    let scaledX = (rawX * scaleY) + horizontalOffset
                    let scaledY = baseSwitchesY * scaleY

                    ToggleSwitchView(
                        onImageName: "on",
                        offImageName: "off",
                        isOn: $viewModel.switchStates[index],
                        scaleFactor: scaleY // Pass the height scale down to scale the frame
                    )
                    .position(x: scaledX, y: scaledY)
                }

                // Validate button scaled uniformly based on height scale factor
                Button(action: validateAndCheck) {
                    ZStack {
                        Circle()
                            .fill(Color.abyssalDanger)
                            .frame(width: buttonDiameter * scaleY, height: buttonDiameter * scaleY)
                            .shadow(color: .abyssalDanger.opacity(0.5), radius: 8 * scaleY)
                        Text("⚡")
                            .font(.system(size: 36 * scaleY))
                    }
                }
                .buttonStyle(.plain)
                .position(
                    x: (buttonX * scaleY) + horizontalOffset,
                    y: buttonY * scaleY
                )
            }
        }
        .onAppear {
            viewModel.onValidationResult = { success in
                dismiss()
                if success {
                    viewModel.handleVictory()
                } else {
                    viewModel.handleGameOver()
                }
            }
        }
        .interactiveDismissDisabled(true)
    }

    // MARK: - Actions
    private func validateAndCheck() {
        viewModel.validateSolution()
    }
}

// MARK: - Preview
#Preview {
    ReactorPuzzleView()
}
