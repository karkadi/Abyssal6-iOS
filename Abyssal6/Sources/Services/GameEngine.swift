//
//  GameEngine.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//

import Foundation
import DIContainer

enum GameEngineKey: DependencyKey {
    static let liveValue: GameEngineProtocol = GameEngine.shared
}

extension DependencyValues {
    var engine: GameEngineProtocol {
        get { self[GameEngineKey.self] }
        set { self[GameEngineKey.self] = newValue }
    }
}

@MainActor
protocol GameEngineProtocol: AnyObject, Sendable {
    var gameState: GameState { get set }
    var timeLeft: Int { get }
    var player: Player { get }

    func startNewGame()
    func startMission()
    func restartGame()
    func handleVictory()
    func handleGameOver()
    func interpretCommand(_ input: String)
    func log(_ message: String)
    func playSound(_ soundFile: String)
    func playBackgroundMusic(_ file: String)
    func stopBackgroundMusic()
    func refreshInventory()
    func showTalkDialog()
    func showItemDetails(_ item: Item)
    func setPlayerRoom(_ room: Room)
}

// MARK: – GameEngine
// swiftlint:disable type_body_length
@MainActor
final class GameEngine: GameEngineProtocol {

    static let shared = GameEngine()

    // MARK: - Published State
    var gameState: GameState = .intro {
        didSet {
            NotificationCenter.default.post(name: .gameStateDidChange, object: gameState)
            if gameState == .playing {
                startTimer()
            }
        }
    }

    private(set) var timeLeft: Int = 600 {
        didSet {
            NotificationCenter.default.post(name: .timeLeftDidChange, object: nil)
            if timeLeft <= 0 && gameState == .playing {
                handleGameOver()
            } else if timeLeft == 10 && gameState == .playing {
                playSound("countdown")
            }
        }
    }

    // MARK: - Game Objects
    private(set) var player: Player
    private(set) var allRooms: [Room] = []
    private(set) var movingCharacters: [MovingCharacter] = []
    private var timerTask: Task<Void, Never>?
    private let musicPlayer = MusicPlayer()
    private var reactorRoom: Room?

    // MARK: - Initialization
    init() {
        let (startRoom, moving) = Room.createRooms()
        self.player = Player(startingRoom: startRoom)
        self.movingCharacters = moving
        moving.first?.setTargetPlayer(player)
        setupGameWorld()
        startNewGame()
    }

    // MARK: - Game Lifecycle
    func startNewGame() {
        gameState = .characterGallery
        timeLeft = 600
    }

    func startMission() {
        gameState = .playing
        playBackgroundMusic("theme")
    }

    func restartGame() {
        // Reinitialize everything
        let (startRoom, moving) = Room.createRooms()
        self.player = Player(startingRoom: startRoom)
        self.movingCharacters = moving
        moving.first?.setTargetPlayer(player)
        setupGameWorld()
        timeLeft = 600
        startMission()
        refreshInventory()
        log(player.currentRoom.longDescription)
    }

    func handleVictory() {
        gameState = .won
        playSound("congratulations")
        log(Lang.string("win"))
    }

    func handleGameOver() {
        gameState = .lost
        playSound("explosion")
        log(Lang.string("game_over_message"))
    }

    // MARK: - Timer
    private func startTimer() {
        Task {
            while timeLeft > 0 {
                try? await Task.sleep(for: .seconds(1))
                timeLeft -= 1
            }
        }
    }

    // MARK: - World Setup
    private func setupGameWorld() {
        // Collect all rooms (recursively from player's starting room)
        allRooms = collectAllRooms(from: player.currentRoom)

        // Find and store reactor room
        reactorRoom = allRooms.first { $0.key == "room_reacteur" }

        // Initialize transporter rooms
        for room in allRooms {
            if let transporter = room as? TransporterRoom {
                transporter.initializeDestinations(allRooms)
            }
        }
    }

    private func collectAllRooms(from start: Room) -> [Room] {
        var visited = Set<Room>()
        var result: [Room] = []
        var queue: [Room] = [start]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            if visited.contains(current) { continue }
            visited.insert(current)
            result.append(current)

            for direction in Direction.allCases {
                if let neighbor = current.getExit(direction.rawValue) {
                    queue.append(neighbor)
                }
            }
        }
        return result
    }

    // MARK: - Character Movement
    func moveAllCharacters() {
        for character in movingCharacters {
            let oldRoom = character.currentRoom
            character.move()
            let newRoom = character.currentRoom

            if oldRoom !== newRoom {
                if newRoom === player.currentRoom {
                    loadAndAddCharacterOverlay(character)
                    log(String(format: Lang.string("character_enters"),
                               character.localizedName))
                }
                if oldRoom === player.currentRoom {
                    removeCharacterOverlay(character)
                    log(String(format: Lang.string("character_leaves"),
                               character.localizedName))
                }
            }
        }
    }

    // MARK: - Command Handling
    // swiftlint:disable cyclomatic_complexity
    func interpretCommand(_ input: String) {
        let parts = input.lowercased().split(separator: " ", maxSplits: 1).map(String.init)
        let commandWord = parts.first?.lowercased() ?? ""
        let argument = parts.count > 1 ? parts[1] : nil

        log("> \(input)")

        switch commandWord {
        case "go": goCommand(direction: argument)
        case "take": takeCommand(itemName: argument)
        case "eat":
            if let argument = argument {
                eatCommand(itemName: argument)
            }
        case "drop": dropCommand(itemName: argument)
        case "inventory": log(player.getInventoryDescription())
        case "inv": log(player.getInventoryDescription())
        case "talk":
            if let argument = argument {
                talkCommand(characterName: argument)
            } else {
                showTalkDialog()   // instead of posting a notification
            }
        case "give":
            if let argument = argument {
                giveCommand(itemName: argument)
            } else {
                showGiveDialog()   // instead of posting a notification
            }
        case "test":
            guard let argument = argument else {
                log(Lang.string("test_error_no_file"))
                return
            }
            runTestFile(argument)
        case "use": useCommand(itemName: argument)
        case "charge": chargeBeamer()
        case "fire": fireBeamer()
        case "look": log(player.currentRoom.longDescription)
        case "back": backCommand()
        case "help": showHelp()
        case "save": saveGame(name: argument)
        case "load": loadGame(name: argument)
        case "quit": quitGame()
        default: log(Lang.string("wrong_command"))
        }

        moveAllCharacters()
    }
    // swiftlint:enable cyclomatic_complexity
    // MARK: - Movement Commands
    private func goCommand(direction: String?) {
        guard let dir = direction else {
            log(Lang.string("where_to_go"))
            return
        }

        let current = player.currentRoom

        if current.isDoorLocked(dir) {
            log(Lang.string("door_locked_message"))
            if let door = current.getDoor(in: dir) {
                let keyName = Lang.string(door.requiredKey.nameKey)
                log(String(format: Lang.string("door_locked_needs"), keyName))
            }
            playSound("access")
            return
        }

        guard let nextRoom = current.getExit(dir) else {
            log(Lang.string("no_door"))
            return
        }

        let isTransporter = current is TransporterRoom
        if isTransporter {
            log(Lang.string("transporter_activated"))
        }

        if current.hasDoor(in: dir) {
            current.doorPassed(dir)
        }

        player.pushHistory()
        setPlayerRoom(nextRoom)

        if isTransporter {
            log(Lang.string("transporter_arrival"))
        }

        playSound("door")

        if nextRoom.isReactor {
            // Show puzzle dialog (handled by UI, but we trigger via notification)
            gameState = .puzzle
        }
    }

    private func backCommand() {
        if player.goBack() {
            playSound("door")
        } else {
            if player.previousRoom == nil {
                log(Lang.string("back_start"))
            } else {
                log(Lang.string("back_trapdoor_blocked"))
            }
        }
    }

    // MARK: - Inventory Commands
    private func takeCommand(itemName: String?) {
        guard let name = itemName else {
            log(Lang.string("take_what"))
            return
        }
        do {
            let item = try player.takeItem(name)
            log(String(format: Lang.string("item_taken"), item.information))
            log(player.weightString)
            NotificationCenter.default.post(name: .inventoryDidChange, object: nil)
            NotificationCenter.default.post(name: .roomDidChange, object: player.currentRoom)
        } catch {
            log(String(format: Lang.string("cannot_take"),
                       Lang.string((error as? GameError)?.resourceKey ?? "")))
        }
    }

    private func dropCommand(itemName: String?) {
        guard let name = itemName else {
            log(Lang.string("drop_what"))
            return
        }
        if let item = player.dropItem(name) {
            log(String(format: Lang.string("item_dropped"), item.information))
            log(player.weightString)
            NotificationCenter.default.post(name: .inventoryDidChange, object: nil)
            NotificationCenter.default.post(name: .roomDidChange, object: player.currentRoom)

        } else {
            log(Lang.string("cannot_drop"))
        }
    }

    // MARK: - Character Interaction
    private func talkCommand(characterName: String?) {
        guard let name = characterName else {
            // Show popup (handled by UI)
            NotificationCenter.default.post(name: .showTalkPopup, object: nil)
            return
        }
        guard let character = player.currentRoom.getCharacter(named: name) else {
            log(String(format: Lang.string("character_not_found"), name))
            return
        }
        log(character.speak())
    }

    private func giveCommand(itemName: String?) {
        guard let name = itemName else {
            NotificationCenter.default.post(name: .showGivePopup, object: nil)
            return
        }
        guard let item = player.inventory.first(where: { $0.name == name }) else {
            log(Lang.string("item_not_in_inventory"))
            return
        }
        let characters = player.currentRoom.characters
        guard !characters.isEmpty else {
            log(Lang.string("no_characters_here"))
            return
        }

        for character in characters {
            if let response = character.reactToItem(item) {
                log(response)
                if character.acceptsExchange(item) {
                    handleExchange(character: character, givenItem: item)
                } else if character.getRequiredItem()?.type == item.type {
                    handleHelp(character: character, givenItem: item)
                } else {
                    log(Lang.string("item_not_consumed"))
                }
                return
            }
        }
        log(Lang.string("no_one_wants_item"))
    }

    private func handleExchange(character: StaticCharacter, givenItem: Item) {
        guard let receivedItem = character.performExchange(given: givenItem) else {
            log(Lang.string("exchange_failed"))
            return
        }
        do {
            try player.exchangeItems(given: givenItem, received: receivedItem)
            log(String(format: Lang.string("exchange_success"),
                       givenItem.information, receivedItem.information))
            refreshInventory()
        } catch {
            log(String(format: Lang.string("cannot_take"),
                       Lang.string((error as? GameError)?.resourceKey ?? "")))
            log(Lang.string("exchange_cancelled"))
        }
    }

    private func handleHelp(character: StaticCharacter, givenItem: Item) {
        //  player.inventory.removeAll { $0.id == givenItem.id }
        player.setCurrentWeight(player.getCurrentWeight() - givenItem.weight)
        log(Lang.string("item_given"))
        log(String(format: Lang.string("help_received"), character.localizedName))
        refreshInventory()
    }

    // MARK: - Beamer Commands
    private func chargeBeamer() {
        guard let beamer = player.findBeamerInInventory() else {
            log(Lang.string("no_beamer"))
            return
        }
        if beamer.isCharged {
            log(Lang.string("beamer_already_charged"))
            return
        }
        beamer.charge(with: player.currentRoom)
        log(String(format: Lang.string("beamer_charged"), player.currentRoom.shortDescription))
        playSound("charge")
        refreshInventory()
    }

    private func fireBeamer() {
        guard let beamer = player.findBeamerInInventory() else {
            log(Lang.string("no_beamer"))
            return
        }
        guard beamer.isCharged else {
            log(Lang.string("beamer_not_charged"))
            return
        }
        guard let targetRoom = beamer.fire() else {
            log(Lang.string("beamer_error"))
            return
        }
        player.pushHistory()
        setPlayerRoom(targetRoom)
        log(Lang.string("beamer_fired"))
        playSound("teleport")
    }

    // MARK: - Other Commands
    private func useCommand(itemName: String?) {
        guard let name = itemName else {
            log(Lang.string("use_what"))
            return
        }
        guard let item = player.inventory.first(where: { $0.name == name }) else {
            log(Lang.string("item_not_in_inventory"))
            return
        }

        // Easter egg: torch in observatory
        if item.type == .torch && player.currentRoom.key == "room_obs" {
            guard let torch = item as? Torch else { return }
            if torch.batteryLife < 15 {
                log(Lang.string("easter_egg_battery_too_low"))
                log(String(format: Lang.string("easter_egg_battery_level"), torch.batteryLife))
                log(Lang.string("easter_egg_charge_needed"))
                return
            }
            log(Lang.string("easter_egg_torch_brandish"))
            log(Lang.string("easter_egg_light_beam"))
            log(Lang.string("easter_egg_secret_message"))
            NotificationCenter.default.post(name: .showEasterEgg, object: torch)
            return
        }

        // Key usage for doors
        let keyTypes: [ItemType] = [.blueCard, .redCard, .wrench, .divingSuit]
        if keyTypes.contains(item.type) {
            var used = false
            for direction in Direction.allCases.map({ $0.rawValue }) where player.currentRoom.hasDoor(in: direction) {
                let door = player.currentRoom.getDoor(in: direction)!
                if door.requiredKey == item.type {
                    used = true
                    if door.isLocked {
                        if player.currentRoom.unlockDoor(direction: direction, with: item) {
                            playSound("granted")
                            log(String(format: Lang.string("door_unlocked_direction"),
                                       Lang.string(direction)))
                        } else {
                            log(Lang.string("wrong_key"))
                        }
                    } else {
                        if player.currentRoom.lockDoor(direction: direction, with: item) {
                            log(String(format: Lang.string("door_locked_direction"),
                                       Lang.string(direction)))
                        } else {
                            log(Lang.string("wrong_key"))
                        }
                    }
                    break
                }

            }
            if !used {
                log(Lang.string("no_compatible_door"))
            }
        } else {
            log(Lang.string("cannot_use_item"))
        }
    }

    private func eatCommand(itemName: String) { // called by interpretCommand if needed
        guard let item = player.eatItem(itemName) else {
            log(Lang.string("item_not_in_room"))
            return
        }
        if let cookie = item as? MagicCookie {
            let oldMax = player.maxWeight
            cookie.applyEffect(player)
            log(Lang.string("ate_magic_cookie"))
            log(String(format: Lang.string("weight_doubled"), oldMax, player.maxWeight))
            playSound("magic")
        } else {
            log(String(format: Lang.string("cannot_eat"), item.information))
        }
    }

    private func showHelp() {
        log(Lang.string("help"))
        log(getCommandWords())
        log(Lang.string("help_beamer"))
        log(Lang.string("help_charge"))
        log(Lang.string("help_fire"))
        log(Lang.string("help_characters"))
        log(Lang.string("help_talk"))
        log(Lang.string("help_give"))
    }

    private func quitGame() {
        gameState = .quit
        log(Lang.string("end_game"))
    }

    // MARK: - UI Helpers
    func setPlayerRoom(_ room: Room) {
        player.setCurrentRoom(room)
        log(room.longDescription)
        NotificationCenter.default.post(name: .roomDidChange, object: room)
        refreshInventory()
        // Update overlays (handled by UI via notification)

    }

    private func showGiveDialog() {
        NotificationCenter.default.post(name: .showGiveDialog,
                                        object: nil)
    }

    func showTalkDialog() {
        NotificationCenter.default.post(name: .showTalkDialog,
                                        object: nil)
    }

    func refreshInventory() {
        NotificationCenter.default.post(name: .inventoryDidChange, object: nil)
    }

    func log(_ message: String) {
        NotificationCenter.default.post(name: .gameLog, object: message)
    }

    func playSound(_ soundFile: String) {
        musicPlayer.playSFX(soundFile)
    }

    func playBackgroundMusic(_ file: String) {
        musicPlayer.playBackgroundMusic(file)
    }

    func stopBackgroundMusic() {
        musicPlayer.stopBackgroundMusic()
    }

    func getCommandWords() -> String {
        return "go, take, drop, inventory, talk, give, use, charge, fire, look, back, help, save, load, quit"
    }

    // MARK: - Overlay Management (notifies UI)
    func loadAndAddCharacterOverlay(_ character: StaticCharacter) {
        NotificationCenter.default.post(name: .addCharacterOverlay,
                                        object: character.nameKey)
    }

    func removeCharacterOverlay(_ character: StaticCharacter) {
        NotificationCenter.default.post(name: .removeCharacterOverlay,
                                        object: character.nameKey)
    }

    func showItemDetails(_ item: Item) {
        NotificationCenter.default.post(name: .showItemDetails,
                                        object: item)
    }

    // MARK: - Test Command
    // swiftlint:disable cyclomatic_complexity
    /// Executes a test script file.
    /// - Parameter fileName: The name of the file (without extension) inside the app bundle.
    /// - Returns: `true` if all checks pass, `false` otherwise.
    @discardableResult
    func runTestFile(_ fileName: String) -> Bool {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "txt") else {
            log("Test file not found: \(fileName).txt")
            return false
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
            var lineNumber = 0
            var executedCommands = 0
            var passed = true

            for rawLine in lines {
                lineNumber += 1
                let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
                if line.isEmpty || line.hasPrefix("#") { continue }

                if line.hasPrefix("roomis ") {
                    let expectedRoom = line.dropFirst(7).trimmingCharacters(in: .whitespaces)
                    if !verifyCurrentRoom(expectedRoom) {
                        log("--- ERROR line \(lineNumber): Should be in '\(expectedRoom)'")
                        passed = false
                    }
                } else if line.hasPrefix("roomhas ") {
                    let itemName = line.dropFirst(8).trimmingCharacters(in: .whitespaces)
                    if !verifyRoomHasItem(itemName) {
                        log("--- ERROR line \(lineNumber): Room should contain '\(itemName)'")
                        passed = false
                    }
                } else if line.hasPrefix("roomhasnot ") {
                    let itemName = line.dropFirst(11).trimmingCharacters(in: .whitespaces)
                    if !verifyRoomHasNotItem(itemName) {
                        log("--- ERROR line \(lineNumber): Room should NOT contain '\(itemName)'")
                        passed = false
                    }
                } else if line.hasPrefix("playerhas ") {
                    let itemName = line.dropFirst(10).trimmingCharacters(in: .whitespaces)
                    if !verifyPlayerHasItem(itemName) {
                        log("--- ERROR line \(lineNumber): Player should have '\(itemName)'")
                        passed = false
                    }
                } else if line.hasPrefix("playerhasnot ") {
                    let itemName = line.dropFirst(13).trimmingCharacters(in: .whitespaces)
                    if !verifyPlayerHasNotItem(itemName) {
                        log("--- ERROR line \(lineNumber): Player should NOT have '\(itemName)'")
                        passed = false
                    }
                } else if line.hasPrefix("settestmode ") {
                    let destination = line.dropFirst(12).trimmingCharacters(in: .whitespaces)
                    setTestModeForAllTransporters(destination)
                    log("Test mode set to: \(destination)")
                } else if line.hasPrefix("cleartestmode") {
                    clearTestModeForAllTransporters()
                    log("Test mode cleared")
                } else {
                    // Normal command
                    log("> \(line)")
                    interpretCommand(line)
                    executedCommands += 1
                }
            }

            log("--- Test summary ---")
            log("File: \(fileName).txt")
            log("Total lines: \(lineNumber)")
            log("Commands executed: \(executedCommands)")
            log(passed ? "--- TEST PASSED ---" : "--- TEST FAILED ---")
            return passed

        } catch {
            log("Error reading test file: \(error.localizedDescription)")
            return false
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func setTestModeForAllTransporters(_ roomKey: String) {
        for room in allRooms where room is TransporterRoom {
            (room as? TransporterRoom)?.setForcedDestination(roomKey)
        }
    }

    func clearTestModeForAllTransporters() {
        for room in allRooms where room is TransporterRoom {
            (room as? TransporterRoom)?.clearForcedDestination()
        }
    }
    // MARK: - Save/Load

    func saveGame(name: String?) {
        guard let name = name, !name.isEmpty else {
            log(Lang.string("save_usage"))
            return
        }
        _ = SaveGameManager.save(gameEngine: self, name: name)
    }

    func loadGame(name: String?) {
        guard let name = name, !name.isEmpty else {
            log(Lang.string("load_usage"))
            return
        }
        _ = SaveGameManager.load(gameEngine: self, name: name)
    }

    func replaceWith(player: Player, allRooms: [Room], movingCharacters: [MovingCharacter], timeLeft: Int) {
        self.player = player
        self.allRooms = allRooms
        self.movingCharacters = movingCharacters
        self.timeLeft = timeLeft

        // Re-initialize transporter destinations
        for room in allRooms {
            if let transporter = room as? TransporterRoom {
                transporter.initializeDestinations(allRooms)
            }
        }

        // Refresh UI
        refreshInventory()
        NotificationCenter.default.post(name: .roomDidChange, object: player.currentRoom)
        log(player.currentRoom.longDescription)
        if gameState != .playing {
            gameState = .playing
        }
    }
    // MARK: - Test helpers

    private func verifyCurrentRoom(_ expectedRoomKey: String) -> Bool {
        return player.currentRoom.key == expectedRoomKey
    }

    private func verifyRoomHasItem(_ itemName: String) -> Bool {
        return player.currentRoom.containsItem(named: itemName)
    }

    private func verifyRoomHasNotItem(_ itemName: String) -> Bool {
        return !player.currentRoom.containsItem(named: itemName)
    }

    private func verifyPlayerHasItem(_ itemName: String) -> Bool {
        return player.hasItem(named: itemName)
    }

    private func verifyPlayerHasNotItem(_ itemName: String) -> Bool {
        return !player.hasItem(named: itemName)
    }
}
// swiftlint:enable type_body_length
