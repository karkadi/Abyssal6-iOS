//
//  Abyssal6App.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI
import DIContainer

@main
struct Abyssal6App: App {
    init() {
        registerSevices()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    // Register Services
    private func registerSevices() {
        DIContainer.shared.register(GameEngineProtocol.self) { GameEngine.shared }
    }
}
