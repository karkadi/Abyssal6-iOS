//
//  IntroView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//

import SwiftUI

// MARK: – Main Intro View (with animations & language picker)

struct IntroView: View {
    @State private var titleOpacity: Double = 1.0
    @State private var showTypewriter = false
    @State private var startGameFlag = false
    @State private var selectedLanguage: Lang.Language = Lang.current

    // MARK: - View Model
    @State private var viewModel = IntroViewModel()

    // Core canvas reference height matching the game engine layout standards
    private let refHeight: CGFloat = 680

    // Skip intro immediately – used by tap gesture and start button
    private func skipToGame() {
        withAnimation(.easeOut(duration: 0.3)) {
            titleOpacity = 0
            startGameFlag = true
            viewModel.stopBackgroundMusic()
        }
    }

    var body: some View {
        GeometryReader { geometry in
            // Calculate scale modifier solely based on device screen height
            let scaleY = geometry.size.height / refHeight

            ZStack {
                // 2. Dark overlay for better text readability
                Color.abyssalBg.opacity(1.0)
                    .ignoresSafeArea()

                // 1. Animated background
                GIFImage(source: "background")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // 3. Main content
                    // Title (fades out after ~3 seconds)
                // Force entire content to redraw when language changes
                VStack(spacing: 10) {
                    Text("ABYSSAL-6")
                    // Size scales proportionally with device height
                        .font(.system(size: 52 * scaleY, weight: .black, design: .monospaced))
                        .foregroundColor(.abyssalText)
                        .shadow(color: .abyssalAccent.opacity(0.8), radius: 12 * scaleY)
                        .opacity(titleOpacity)
                        .task {
                            // 1. Show typewriter after 0.5 seconds
                            do {
                                try await Task.sleep(for: .seconds(0.5))
                                showTypewriter = true

                                // 2. Wait the remaining 12.5 seconds (to hit the total 13.0 second mark)
                                try await Task.sleep(for: .seconds(5.0))
                                withAnimation(.easeOut(duration: 5.0)) {
                                    titleOpacity = 0
                                }
                            } catch {
                                // Handles cancellation gracefully if the user skips or leaves the view
                            }
                        }

                    // Typewriter text – appears only after title starts fading
                    if showTypewriter && !startGameFlag {
                        TypewriterText(Lang.string("introduction"), scaleY: scaleY) {
                            viewModel.playBackgroundMusic("typewriter")
                        } onComplete: {
                            viewModel.stopBackgroundMusic()
                        }
                    }

                    Spacer()

                    // Buttons – always visible, but hidden when game starts
                    if !startGameFlag {
                        HStack(spacing: 40 * scaleY) {
                            // Language picker menu
                            Menu {
                                ForEach(Lang.Language.allCases, id: \.self) { lang in
                                    Button(action: {
                                        selectedLanguage = lang
                                        Lang.current = lang
                                    }, label: {
                                        Text(lang.displayName)
                                        if lang == selectedLanguage {
                                            Image(systemName: "checkmark")
                                        }
                                    })
                                }
                            } label: {
                                HStack {
                                    Text(selectedLanguage.displayName)
                                        .font(.system(size: 20 * scaleY, design: .monospaced))
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.abyssalAccent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.abyssalAccent, lineWidth: 1)
                                        .background(Color.abyssalPanel.opacity(0.8))
                                )
                            }
                            .scaleEffect(scaleY, anchor: .center)

                            // Start button
                            AbyssalButton(title: Lang.string("start_game"),
                                          color: .abyssalAccent, scaleY: 2.0 * scaleY) {
                                skipToGame()
                            }
                            .scaleEffect(scaleY, anchor: .center)
                        }
                    }
                }
                // Adaptive layout padding that shrinks to prevent layout cutoff on narrow screens
                .padding(20 * scaleY)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Force view redraw when language changes
                .id(selectedLanguage.rawValue)
            }
        }
        // Tap anywhere to skip intro (Java behaviour)
        .onTapGesture {
            skipToGame()
        }
        // When startGameFlag becomes true, notify the engine
        .onChange(of: startGameFlag) { _, newValue in
            if newValue {
                viewModel.startMission()
            }
        }
    }
}

// MARK: – Preview

#Preview {
    IntroView()
}
