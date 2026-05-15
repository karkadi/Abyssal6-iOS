//
//  IntroView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

// MARK: – Color Palette (mirrors Java FRAME_BG / ACCENT)

extension Color {
    static let abyssalBg      = Color(red: 0.10, green: 0.12, blue: 0.18)
    static let abyssalPanel   = Color(red: 0.13, green: 0.16, blue: 0.23)
    static let abyssalAccent  = Color(red: 0.20, green: 0.70, blue: 0.90)
    static let abyssalButton  = Color(red: 0.16, green: 0.22, blue: 0.32)
    static let abyssalText    = Color(red: 0.85, green: 0.95, blue: 1.00)
    static let abyssalDim     = Color(red: 0.50, green: 0.65, blue: 0.80)
    static let abyssalDanger  = Color(red: 1.0, green: 0.19, blue: 0.13)
    static let abyssalSuccess = Color(red: 0.20, green: 0.80, blue: 0.40)
}

// MARK: – Main Intro View (with animations)

struct IntroView: View {
    @Environment(GameEngine.self) private var engine
    @State private var titleOpacity: Double = 1.0
    @State private var showTypewriter = false
    @State private var startGameFlag = false
    
    // Core canvas reference height matching the game engine layout standards
    private let refHeight: CGFloat = 680
    
    // Skip intro immediately – used by tap gesture and start button
    private func skipToGame() {
        withAnimation(.easeOut(duration: 0.3)) {
            titleOpacity = 0
            startGameFlag = true
            engine.stopBackgroundMusic()
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
                VStack(spacing: 10) { // Spacing scales down on shorter devices
                    // Title (fades out after ~3 seconds)
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
                            engine.playBackgroundMusic("typewriter")
                        } onComplete: {
                            engine.stopBackgroundMusic()
                        }
                        
                    }
                    
                    Spacer()
                    
                    // Buttons – always visible, but hidden when game starts
                    if !startGameFlag {
                        AbyssalButton(title: Lang.string("start_game"),
                                      color: .abyssalAccent) {
                            skipToGame()
                        }
                        // Scale the button frame/content layout directly
                                      .scaleEffect(scaleY, anchor: .center)
                        
                    }
                }
                // Adaptive layout padding that shrinks to prevent layout cutoff on narrow screens
                 .padding(40 * scaleY)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        // Tap anywhere to skip intro (Java behaviour)
        .onTapGesture {
            skipToGame()
        }
        // When startGameFlag becomes true, notify the engine
        .onChange(of: startGameFlag) { _, newValue in
            if newValue {
                engine.startMission()
            }
        }
    }
}

// MARK: – Preview

#Preview {
    IntroView()
        .environment(GameEngine())
}
