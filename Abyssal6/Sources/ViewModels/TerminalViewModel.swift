//
//  TerminalViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 16/05/2026.
//
import Foundation
// MARK: - Terminal View Model

@Observable
@MainActor
final class TerminalViewModel {
    private(set) var fullText: String = ""
    private var pendingText: String = ""
    private var typewriterTask: Task<Void, Never>?
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
        // 1. Cancel any ongoing typing task immediately
        stopTypewriter()

        pendingText = message
        currentIndex = 0
        isTyping = true

        // 2. Start a new asynchronous Task isolated to the MainActor
        typewriterTask = Task { @MainActor in
            // Loop through each character index safely
            while currentIndex < pendingText.count {

                // 3. Check for cooperative cancellation before appending characters
                if Task.isCancelled { break }

                let index = pendingText.index(pendingText.startIndex, offsetBy: currentIndex)
                fullText.append(pendingText[index])
                currentIndex += 1

                // Optional: Insert audio triggering here if soundEnabled is true

                // 4. Sleep asynchronously without blocking the main UI thread
                // Convert TimeInterval (seconds) to nanoseconds or use duration types
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }

            // 5. If the animation completed without being cancelled, clean up
            if !Task.isCancelled {
                fullText.append("\n")
                isTyping = false
                typewriterTask = nil
            }
        }
    }

    func clear() {
        stopTypewriter()
        fullText = ""
        pendingText = ""
        currentIndex = 0
    }

    func stopTypewriter() {
        typewriterTask?.cancel()
        typewriterTask = nil
        isTyping = false
    }
}
