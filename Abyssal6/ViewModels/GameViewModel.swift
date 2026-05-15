//
//  GameViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

/// The main view model for the game, acting as the bridge between the GameEngine and SwiftUI views.
/// Uses the `@Observable` macro (iOS 17+) for automatic observation of properties.
@Observable
final class GameViewModel {
    // MARK: - Dependencies
    var transitionOverlayVM: TransitionOverlayViewModel = TransitionOverlayViewModel()
    var terminalVM: TerminalViewModel = TerminalViewModel()
    
    // MARK: - UI State (observed by SwiftUI)
    private(set) var terminalText: String = ""
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
    var displayedItemForDetails: Item? = nil
    var giveDialogData: GiveDialogData? = nil
    var talkDialogCharacters: TalkDialogData? = nil
    var easterEggTorch: Torch? = nil
    
    var gameOverFlag = false
    var victoryFlag = false
    
    // MARK: - Initialization
    init() {
        // Observe engine changes (if engine itself is @Observable, we can use `withObservationTracking`
        // but for simplicity we'll manually refresh after each command.
        
        terminalVM.append("Welcome to Abyssal-6")
        terminalVM.append(Lang.string("welcome"))
        // terminalVM.typewrite(Lang.string("welcome"), delay: 0.05)
    }
    
    // MARK: - Public Methods for Views
    func sendCommand(_ input: String, engine: GameEngine) {
        appendToTerminal("> \(input)")
        engine.interpretCommand(input)
        refreshUI(engine)
        
        // After each command, refresh inventory popup if open (via notification or delegate)
        NotificationCenter.default.post(name: .gameStateDidChange, object: nil)
    }
    
    func refreshUI(_ engine: GameEngine) {
        currentRoomName = engine.player.currentRoom.shortDescription
        currentRoomImageName = engine.player.currentRoom.imageName
        currentRoomDescription = engine.player.currentRoom.longDescription
        inventoryItems = engine.player.inventory
        roomItems = engine.player.currentRoom.items
        roomCharacters = engine.player.currentRoom.characters
    }
    
    func appendToTerminal(_ message: String) {
        terminalText += message + "\n"
    }
    
    func clearTerminal() {
        terminalText = ""
    }
    
    // MARK: - Inventory Actions
    func takeItem(_ item: Item, engine: GameEngine) {
        sendCommand("take \(item.name)", engine: engine)
    }
    
    func dropItem(_ item: Item, engine: GameEngine) {
        sendCommand("drop \(item.name)", engine: engine)
    }
    
    func useItem(_ item: Item, engine: GameEngine) {
        sendCommand("use \(item.name)", engine: engine)
    }
    
    func eatItem(_ item: Item, engine: GameEngine) {
        sendCommand("eat \(item.name)", engine: engine)
    }
    
    func showItemDetails(_ item: Item) {
        displayedItemForDetails = item
    }
    
    func dismissItemDetails() {
        displayedItemForDetails = nil
    }
    
    func showGiveDialog(player: Player) {
        let characters = player.currentRoom.characters.filter { !($0 is Player) }
        let inventory = player.inventory
        giveDialogData = GiveDialogData(characters: characters, inventory: inventory)
    }
    
    func dismissGiveDialog() {
        giveDialogData = nil
    }
    
    func showTalkDialog(player: Player) {
        let characters = player.currentRoom.characters.filter { !($0 is Player) }
        talkDialogCharacters = TalkDialogData(characters: characters)
    }
    
    func dismissTalkDialog() {
        talkDialogCharacters = nil
    }
    
    /// Called when a character is selected from the dialog
    func talkToCharacter(nameKey: String, engine: GameEngine) {
        engine.interpretCommand("talk \(nameKey)")
        dismissTalkDialog()
    }
    
    /// Called when the user selects a character and an item.
    func giveItemToCharacter(characterNameKey: String?, item: Item?, engine: GameEngine) {
        guard let charName = characterNameKey, let item = item else {
            engine.log(Lang.string("give_cancelled"))
            return
        }
        engine.interpretCommand("give \(item.name)")
    }
    
    // MARK: - StaticCharacter Interaction
    func talkToCharacter(_ character: StaticCharacter, engine: GameEngine) {
        sendCommand("talk \(character.nameKey)", engine: engine)
    }
    
    func giveItemToCharacter(_ character: StaticCharacter, item: Item, engine: GameEngine) {
        sendCommand("give \(item.name)", engine: engine)
    }
    
    func showTalkPopup(for character: StaticCharacter, engine: GameEngine) {
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
    func restartGame(_ engine: GameEngine) {
        engine.restartGame()
        clearTerminal()
        refreshUI(engine)
        appendToTerminal(Lang.string("game_restarted"))
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
