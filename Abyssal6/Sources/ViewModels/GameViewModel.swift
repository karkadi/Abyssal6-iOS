//
//  GameViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI
import DIContainer

@Observable
@MainActor
final class GameViewModel {
    // MARK: - Dependencies
    var transitionOverlayVM = TransitionOverlayViewModel()
    var terminalVM = TerminalViewModel()

    @ObservationIgnored
    @Injected(\.engine) private var engine: GameEngineProtocol

    @ObservationIgnored
    @Injected(\.coordinator) var coordinator: AppCoordinator

    // MARK: - UI State
    private(set) var currentRoomName = ""
    var currentRoomImageName = ""
    private(set) var currentRoomDescription = ""
    private(set) var inventoryItems: [Item] = []
    private(set) var roomItems: [Item] = []
    private(set) var roomCharacters: [StaticCharacter] = []
    var timeString = "10:00"

    init() {
        terminalVM.append("Welcome to Abyssal-6")
        terminalVM.append(Lang.string("welcome"))
    }

    func updateTime() {
        let seconds = engine.timeLeft
        let minutes = seconds / 60
        let secs = seconds % 60
        timeString = String(format: "%02d:%02d", minutes, secs)
    }

    func interpretCommand(_ input: String) { engine.interpretCommand(input) }

    func sendCommand(_ input: String) {
        interpretCommand(input)
        refreshUI()
    }

    func refreshUI() {
        currentRoomName = engine.player.currentRoom.shortDescription
        currentRoomImageName = engine.player.currentRoom.imageName
        currentRoomDescription = engine.player.currentRoom.longDescription
        inventoryItems = engine.player.inventory
        roomItems = engine.player.currentRoom.items
        roomCharacters = engine.player.currentRoom.characters
    }

    // MARK: - Inventory Actions
    func takeItem(_ item: Item) { sendCommand("take \(item.name)") }
    func dropItem(_ item: Item) { sendCommand("drop \(item.name)") }
    func useItem(_ item: Item) { sendCommand("use \(item.name)") }
    func eatItem(_ item: Item) { sendCommand("eat \(item.name)") }

    func showItemDetails(_ item: Item) { coordinator.showItemDetails(item) }

    func showGiveDialog() {
        coordinator.showGiveDialog(
            characters: engine.player.currentRoom.characters,
            inventory: engine.player.inventory
        )
    }

    func showTalkDialog() {
        coordinator.showTalkDialog(characters: engine.player.currentRoom.characters)
    }

    func talkToCharacter(nameKey: String) {
        interpretCommand("talk \(nameKey)")
        coordinator.dismissTalkDialog()
    }

    func giveItemToCharacter(characterNameKey: String?, item: Item?) {
        guard characterNameKey != nil, let item = item else {
            engine.log(Lang.string("give_cancelled"))
            return
        }
        interpretCommand("give \(item.name)")
    }

    func talkToCharacter(_ character: StaticCharacter) {
        sendCommand("talk \(character.nameKey)")
    }

    func giveItemToCharacter(_ character: StaticCharacter, item: Item) {
        sendCommand("give \(item.name)")
    }

    func showTalkPopup(for character: StaticCharacter) {
        coordinator.showCharacterInteraction(character: character, mode: .talk)
    }

    func showGivePopup(for character: StaticCharacter) {
        coordinator.showCharacterInteraction(character: character, mode: .give)
    }

    func showEasterEgg(for torch: Torch) { coordinator.showEasterEgg(torch: torch) }

    func restartGame() {
        engine.restartGame()
        refreshUI()
    }
}

// MARK: - Interaction Mode Enum
enum CharacterInteractionMode {
    case talk, give
}
