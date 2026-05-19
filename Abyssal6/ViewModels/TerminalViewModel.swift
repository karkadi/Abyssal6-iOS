//
//  TerminalViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 16/05/2026.
//
import Foundation
// MARK: - Terminal View Model

@Observable
final class TerminalViewModel {
    private(set) var fullText: String = ""
    private var pendingText: String = ""
    private var typewriterTimer: Timer?
    private var currentIndex = 0
    private var isTyping = false

    var text: String { fullText }

    /// Instantly appends a message (no animation).
    func append(_ message: String) {
        stopTypewriter()
        fullText += message + "\n"
    }

    /// Appends a message with a typewriter effect (character by character).
    /// - Parameters:
    ///   - message: The text to display.
    ///   - delay: Seconds between each character (default 0.03).
    ///   - soundEnabled: If true, plays a typewriter sound (requires audio setup).
    func typewrite(_ message: String, delay: TimeInterval = 0.03, soundEnabled: Bool = true) {
        stopTypewriter()
        pendingText = message
        currentIndex = 0
        isTyping = true

        typewriterTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.currentIndex < self.pendingText.count {
                let index = self.pendingText.index(self.pendingText.startIndex, offsetBy: self.currentIndex)
                self.fullText.append(self.pendingText[index])
                self.currentIndex += 1

            } else {
                self.fullText.append("\n")
                self.stopTypewriter()
            }
        }
    }

    func clear() {
        stopTypewriter()
        fullText = ""
        pendingText = ""
        currentIndex = 0
    }

    private func stopTypewriter() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
        isTyping = false
    }
}
