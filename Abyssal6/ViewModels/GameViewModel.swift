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
       
    var timeString: String {
        let seconds: Int = engine.timeLeft
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol
    
    // MARK: - Initialization
    init() {
        // Observe engine changes (if engine itself is @Observable, we can use `withObservationTracking`
        // but for simplicity we'll manually refresh after each command.
        
        terminalVM.append("Welcome to Abyssal-6")
        terminalVM.append(Lang.string("welcome"))
        // terminalVM.typewrite(Lang.string("welcome"), delay: 0.05)
    }
    
    // MARK: - Public Methods for Views
    
    func interpretCommand(_ input: String) {
        engine.interpretCommand(input)
    }
    
    func sendCommand(_ input: String) {
        appendToTerminal("> \(input)")
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
    
    func appendToTerminal(_ message: String) {
        terminalText += message + "\n"
    }
    
    func clearTerminal() {
        terminalText = ""
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
        let characters = engine.player.currentRoom.characters.filter { !($0 is Player) }
        let inventory = engine.player.inventory
        giveDialogData = GiveDialogData(characters: characters, inventory: inventory)
    }
    
    func dismissGiveDialog() {
        giveDialogData = nil
    }
    
    func showTalkDialog() {
        let characters = engine.player.currentRoom.characters.filter { !($0 is Player) }
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
        guard let charName = characterNameKey, let item = item else {
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
        clearTerminal()
        refreshUI()
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
