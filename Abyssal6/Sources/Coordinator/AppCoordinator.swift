//
//  AppCoordinator.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 22/05/2026.
//

import SwiftUI
import DIContainer

@Observable
@MainActor
final class AppCoordinator {
    // MARK: - Root navigation
    var gameState: GameState = .characterGallery

    // MARK: - MainGameView sheet states
    var showingInventory = false
    var showingCharacterInteraction = false
    var characterInteractionMode: CharacterInteractionMode = .talk
    var selectedCharacter: StaticCharacter?
    var displayedItemForDetails: Item?
    var giveDialogData: GiveDialogData?
    var talkDialogCharacters: TalkDialogData?
    var easterEggTorch: Torch?

    // MARK: - Dependencies
    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol

    // MARK: - Initialization
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameStateDidChange),
            name: .gameStateDidChange,
            object: nil
        )
    }

    @objc private func gameStateDidChange(_ notification: Notification) {
        if let newState = notification.object as? GameState {
            gameState = newState
        }
    }

    // MARK: - Navigation methods
    func showInventory() { showingInventory = true }
    func dismissInventory() { showingInventory = false }
    func showIntro() { gameState = .intro }
    func showCharacterInteraction(character: StaticCharacter, mode: CharacterInteractionMode) {
        selectedCharacter = character
        characterInteractionMode = mode
        showingCharacterInteraction = true
    }
    func dismissCharacterInteraction() {
        showingCharacterInteraction = false
        selectedCharacter = nil
    }

    func showItemDetails(_ item: Item) { displayedItemForDetails = item }
    func dismissItemDetails() { displayedItemForDetails = nil }

    func showGiveDialog(characters: [StaticCharacter], inventory: [Item]) {
        giveDialogData = GiveDialogData(characters: characters, inventory: inventory)
    }
    func dismissGiveDialog() { giveDialogData = nil }

    func showTalkDialog(characters: [StaticCharacter]) {
        talkDialogCharacters = TalkDialogData(characters: characters)
    }
    func dismissTalkDialog() { talkDialogCharacters = nil }

    func showEasterEgg(torch: Torch) { easterEggTorch = torch }
    func dismissEasterEgg() { easterEggTorch = nil }

    // MARK: - Global actions
    func restartGame() { engine.restartGame() }
}
