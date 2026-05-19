//
//  TypewriterText.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

// MARK: – Typewriter Text View (replicates TransparentTextArea)

struct TypewriterText: View {
    let fullText: String
    let scaleY: CGFloat
    let delay: TimeInterval          // milliseconds per character
    let onStartTyping: (() -> Void)?
    let onComplete: (() -> Void)?

    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var timer: Timer?

    init(
        _ fullText: String,
        scaleY: CGFloat = 1.0,
        delay: TimeInterval = 0.03,
        onStartTyping: (() -> Void)? = nil,
        onComplete: (() -> Void)? = nil
    ) {
        self.fullText = fullText
        self.scaleY = scaleY
        self.delay = delay
        self.onStartTyping = onStartTyping
        self.onComplete = onComplete
    }

    var body: some View {
        ScrollView {
            Text(displayedText)
                .font(.system(size: 20 * scaleY, design: .monospaced))
                .foregroundColor(.abyssalText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.abyssalPanel.opacity(0.01))
        .cornerRadius(12)
        .onAppear(perform: startTyping)
        .onDisappear { timer?.invalidate() }
    }

    private func startTyping() {
        displayedText = ""
        currentIndex = 0
        onStartTyping?()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { _ in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer?.invalidate()
                timer = nil
                onComplete?()
            }
        }
    }
}
