//
//  RootViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 19/05/2026.

import SwiftUI
import DIContainer

@Observable
@MainActor
final class RootViewModel {
    @ObservationIgnored
    @Injected private var coordinator: AppCoordinator

    var gameState: GameState { coordinator.gameState }

    func restartGame() {
        coordinator.restartGame()
    }

}
