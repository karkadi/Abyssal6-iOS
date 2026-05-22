//
//  VoltmeterView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

/// A custom analog voltmeter with a moving needle and a voltage display.
/// The needle position is interpolated between 0V (left) and 10V (right).
struct VoltmeterView: View {
    /// Voltage value (0.0 … 10.0)
    let voltage: Double

    // Reference coordinates from the original Java PuzzlePage (900x680 canvas)
    private let refCenter = CGPoint(x: 638, y: 296)
    private let refZero   = CGPoint(x: 605, y: 270)
    private let refMax    = CGPoint(x: 671, y: 270)

    // Maximum voltage represented (10V)
    private let maxVoltage: Double = 10.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (voltmeter face)
                Image("schema")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)

                // Needle drawn with Canvas
                Canvas { context, size in
                    let scaleX = size.width / 900
                    let scaleY = size.height / 680

                    let center = CGPoint(
                        x: refCenter.x * scaleX,
                        y: refCenter.y * scaleY
                    )
                    let zero = CGPoint(
                        x: refZero.x * scaleX,
                        y: refZero.y * scaleY
                    )
                    let maxPoint = CGPoint(
                        x: refMax.x * scaleX,
                        y: refMax.y * scaleY
                    )
                    // 1. Calculate the physical radius (needle length) using the start point
                    let deltaX = zero.x - center.x
                    let deltaY = zero.y - center.y
                    let radius = sqrt(deltaX*deltaX + deltaY*deltaY)

                    // 2. Determine start and end angles relative to the pivot center
                    let startAngle = atan2(zero.y - center.y, zero.x - center.x)
                    let endAngle = atan2(maxPoint.y - center.y, maxPoint.x - center.x)

                    // 3. Linearly interpolate the angle based on the voltage ratio
                    let ratio = min(max(voltage / maxVoltage, 0.0), 1.0)
                    let currentAngle = startAngle + (endAngle - startAngle) * ratio

                    // 4. Trace the exact arc end-point using trig (radius remains uniform)
                    let needleEnd = CGPoint(
                        x: center.x + radius * cos(currentAngle),
                        y: center.y + radius * sin(currentAngle)
                    )
                    var path = Path()
                    path.move(to: center)
                    path.addLine(to: needleEnd)

                    context.stroke(path, with: .color(.red), lineWidth: 2)

                    // Draw the pivot point
                    context.fill(
                        Path(ellipseIn: CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)),
                        with: .color(.gray)
                    )
                }
                .frame(width: geometry.size.width, height: geometry.size.height)

                // Digital voltage display
                Text(String(format: "%.2f V", voltage))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                    .position(x: geometry.size.width - 28, y: geometry.size.height - 10)
            }
        }
        .aspectRatio(900/680, contentMode: .fit)  // match original aspect ratio
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        VoltmeterView(voltage: 0.0)
            .frame(width: 300, height: 226)
        VoltmeterView(voltage: 3.3)
            .frame(width: 300, height: 226)
        VoltmeterView(voltage: 10.0)
            .frame(width: 300, height: 226)
    }
    .padding()
    .background(Color.black)
}
