//
//  IntroViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 19/05/2026.
//
import SwiftUI
import DIContainer

@Observable
@MainActor
final class IntroViewModel {
    @ObservationIgnored
    @Injected(\.engine) private var engine: GameEngineProtocol

    func stopBackgroundMusic() {
        engine.stopBackgroundMusic()
    }

    func startMission() {
        engine.restartGame()
    }

    func playBackgroundMusic(_ file: String) {
        engine.playBackgroundMusic(file)
    }

}
