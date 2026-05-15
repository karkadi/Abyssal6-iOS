//
//  PuzzleViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

/// View model for the reactor puzzle (8 switches, voltmeter, success condition).
@Observable
final class PuzzleViewModel {
    // MARK: - Constants (mirrors Java PuzzlePage)
    private let resistors: [Double] = [300, 800, 900, 600, 800, 900, 600, 800]
    private let voltageSources: [Double] = [9.0, 9.0, 9.0, 1.5, 1.5, 1.5, 0.0, 0.0]
    private let successMinVoltage: Double = 3.2
    private let successMaxVoltage: Double = 3.4

    // MARK: - Published State
    var switchStates: [Bool] = Array(repeating: false, count: 8) {
        didSet { recalculateVoltage() }
    }
    private(set) var currentVoltage: Double = 0.0

    // Closure called when the user validates the solution (by pressing the red button)
    var onValidationResult: ((Bool) -> Void)?

    // MARK: - Initialization
    init() {
        // Optionally randomize initial states (Java used random.nextBoolean())
        for i in 0..<switchStates.count {
            switchStates[i] = Bool.random()
        }
        recalculateVoltage()
    }

    // MARK: - Public Methods
    /// Call this when the red button is pressed.
    func validateSolution() {
        let isCorrect = (currentVoltage >= successMinVoltage && currentVoltage <= successMaxVoltage)
        onValidationResult?(isCorrect)
    }

    // MARK: - Private Helpers
    private func recalculateVoltage() {
        var numerator = 0.0   // Σ (Vᵢ / Rᵢ)
        var denominator = 0.0 // Σ (1 / Rᵢ)
        var anySwitchOn = false

        for i in 0..<switchStates.count where switchStates[i] {
            numerator += voltageSources[i] / resistors[i]
            denominator += 1.0 / resistors[i]
            anySwitchOn = true
        }

        currentVoltage = anySwitchOn ? (numerator / denominator) : 0.0
    }
}
