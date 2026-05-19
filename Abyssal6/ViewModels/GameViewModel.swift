//
//  GameViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI
import DIContainer

/// The main view model for the game, acting as the bridge between the GameEngine and SwiftUI views.
/// Uses the `@Observable` macro (iOS 17+) for automatic observation of properties.
@Observable
final class GameViewModel {
    // MARK: - Dependencies
    var transitionOverlayVM: TransitionOverlayViewModel = TransitionOverlayViewModel()
    var terminalVM: TerminalViewModel = TerminalViewModel()

    // MARK: - UI State (observed by SwiftUI)
    private(set) var currentRoomName: String = ""
    var currentRoomImageName: String = ""
    private(set) var currentRoomDescription: String = ""
    private(set) var inventoryItems: [Item] = []
    private(set) var roomItems: [Item] = []
    private(set) var roomCharacters: [StaticCharacter] = []

    // Sheet presentation flags
    var showingInventory = false
    var showingCharacterInteraction = false
    var characterInteractionMode: CharacterInteractionMode = .talk
    var selectedCharacter: StaticCharacter?
    var displayedItemForDetails: Item?
    var giveDialogData: GiveDialogData?
    var talkDialogCharacters: TalkDialogData?
    var easterEggTorch: Torch?

    // This property is tracked by SwiftUI
    var timeString: String = "10:00"

    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol

    // MARK: - Initialization

    init() {
        terminalVM.append("Welcome to Abyssal-6")
        terminalVM.append(Lang.string("welcome"))
        // terminalVM.typewrite(Lang.string("welcome"), delay: 0.05)
        // Start listening to the engine's stream immediately on initialization
    }

    func updateTime() {
        let seconds = engine.timeLeft
        let minutes = seconds / 60
        let secs = seconds % 60
        self.timeString =  String(format: "%02d:%02d", minutes, secs)
    }

    // MARK: - Public Methods for Views

    func interpretCommand(_ input: String) {
        engine.interpretCommand(input)
    }

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
    func takeItem(_ item: Item) {
        sendCommand("take \(item.name)")
    }

    func dropItem(_ item: Item) {
        sendCommand("drop \(item.name)")
    }

    func useItem(_ item: Item) {
        sendCommand("use \(item.name)")
    }

    func eatItem(_ item: Item) {
        sendCommand("eat \(item.name)")
    }

    func showItemDetails(_ item: Item) {
        displayedItemForDetails = item
    }

    func dismissItemDetails() {
        displayedItemForDetails = nil
    }

    func showGiveDialog() {
        let characters = engine.player.currentRoom.characters
        let inventory = engine.player.inventory
        giveDialogData = GiveDialogData(characters: characters, inventory: inventory)
    }

    func dismissGiveDialog() {
        giveDialogData = nil
    }

    func showTalkDialog() {
        let characters = engine.player.currentRoom.characters
        talkDialogCharacters = TalkDialogData(characters: characters)
    }

    func dismissTalkDialog() {
        talkDialogCharacters = nil
    }

    /// Called when a character is selected from the dialog
    func talkToCharacter(nameKey: String) {
        interpretCommand("talk \(nameKey)")
        dismissTalkDialog()
    }

    /// Called when the user selects a character and an item.
    func giveItemToCharacter(characterNameKey: String?, item: Item?) {
        guard characterNameKey != nil, let item = item else {
            engine.log(Lang.string("give_cancelled"))
            return
        }
        interpretCommand("give \(item.name)")
    }

    // MARK: - StaticCharacter Interaction
    func talkToCharacter(_ character: StaticCharacter) {
        sendCommand("talk \(character.nameKey)")
    }

    func giveItemToCharacter(_ character: StaticCharacter, item: Item) {
        sendCommand("give \(item.name)")
    }

    func showTalkPopup(for character: StaticCharacter) {
        selectedCharacter = character
        characterInteractionMode = .talk
        showingCharacterInteraction = true
    }

    func showGivePopup(for character: StaticCharacter) {
        selectedCharacter = character
        characterInteractionMode = .give
        showingCharacterInteraction = true
    }

    func showEasterEgg(for torch: Torch) {
        easterEggTorch = torch
    }

    // MARK: - Game Control
    func restartGame() {
        engine.restartGame()
        refreshUI()
    }

    func quitGame() {
        // In a real app, you might show a confirmation dialog.
        // For now, just exit (not recommended for App Store, but for simulation).
        exit(0)
    }
}

// MARK: - Interaction Mode Enum
enum CharacterInteractionMode {
    case talk, give
}
