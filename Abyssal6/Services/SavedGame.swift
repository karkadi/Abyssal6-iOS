//
//  SavedGame.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 20/05/2026.
//

import Foundation

// MARK: - Save Data Structures

struct SavedGame: Codable {
    let version: Int
    let timeLeft: Int
    let player: SavedPlayer
    let rooms: [String: SavedRoom]
    let movingCharacters: [SavedMovingCharacter]
}

struct SavedPlayer: Codable {
    let currentRoomKey: String
    let maxWeight: Int
    let currentWeight: Int
    let historyKeys: [String]
    let inventory: [SavedItem]
}

struct SavedRoom: Codable {
    var doors: [String: SavedDoor]
    var items: [SavedItem]
}

struct SavedDoor: Codable {
    let isLocked: Bool
}

struct SavedItem: Codable {
    let type: String       // ItemType rawValue
    let isBeamerCharged: Bool?
    let beamerRoomKey: String?
    let torchBattery: Int?
    let divingSuitOxygen: Int?
    // MagicCookie has no extra state
}

struct SavedMovingCharacter: Codable {
    let nameKey: String
    let currentRoomKey: String
    let strategy: String   // MovementStrategy rawValue
    let pathIndex: Int?
    let pathKeys: [String]?
}

// MARK: - Save Manager

final class SaveGameManager {
    private static let userDefaultsKey = "Abyssal6_SaveGame"
    private static let currentVersion = 1

    static func save(gameEngine: GameEngine, name: String) -> Bool {
        guard gameEngine.gameState == .playing else {
            gameEngine.log("Can only save while playing.")
            return false
        }

        let player = gameEngine.player
        let timeLeft = gameEngine.timeLeft

        // Player data
        let savedPlayer = SavedPlayer(
            currentRoomKey: player.currentRoom.key,
            maxWeight: player.maxWeight,
            currentWeight: player.currentWeight,
            historyKeys: player.history.map { $0.key },
            inventory: player.inventory.map { savedItem(from: $0) }
        )

        // Rooms modifications (doors lock states + items)
        var roomsDict = [String: SavedRoom]()
        for room in gameEngine.allRooms {
            var doors = [String: SavedDoor]()
            for direction in Direction.allCases.map({ $0.rawValue }) {
                if room.hasDoor(in: direction) {
                    let door = room.getDoor(in: direction)!
                    doors[direction] = SavedDoor(isLocked: door.isLocked)
                }
            }
            let items = room.items.map { savedItem(from: $0) }
            roomsDict[room.key] = SavedRoom(doors: doors, items: items)
        }

        // Moving characters
        let movingChars = gameEngine.movingCharacters.map { character -> SavedMovingCharacter in
            var pathKeys: [String]?
            var pathIndex: Int?
            if character.getStrategy() == .followPath {
                pathKeys = character.getPath().map { $0.key }
                pathIndex = character.getPathIndex()
            }
            return SavedMovingCharacter(
                nameKey: character.nameKey,
                currentRoomKey: character.currentRoom.key,
                strategy: character.getStrategy().rawValue,
                pathIndex: pathIndex,
                pathKeys: pathKeys
            )
        }

        let save = SavedGame(
            version: currentVersion,
            timeLeft: timeLeft,
            player: savedPlayer,
            rooms: roomsDict,
            movingCharacters: movingChars
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(save) else {
            gameEngine.log("Failed to encode save data.")
            return false
        }

        // Save to UserDefaults with the given name
        var saves = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Data] ?? [:]
        saves[name] = data
        UserDefaults.standard.set(saves, forKey: userDefaultsKey)

        gameEngine.log("Game saved as '\(name)'")
        return true
    }

    static func load(gameEngine: GameEngine, name: String) -> Bool {
        guard let saves = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: Data],
              let data = saves[name] else {
            gameEngine.log("Save file '\(name)' not found.")
            return false
        }

        let decoder = JSONDecoder()
        guard let savedGame = try? decoder.decode(SavedGame.self, from: data) else {
            gameEngine.log("Failed to decode save data.")
            return false
        }

        // Rebuild the world from scratch (fresh rooms and characters)
        let (startRoom, movingCharacters) = GameEngine.createRooms()
        let allRooms = collectAllRooms(from: startRoom)

        // Map room keys to Room objects
        var roomMap = [String: Room]()
        for room in allRooms {
            roomMap[room.key] = room
        }

        // Apply room modifications (door locks, items)
        for (roomKey, savedRoom) in savedGame.rooms {
            guard let room = roomMap[roomKey] else { continue }
            // Clear existing items
            for item in room.items {
                room.removeItem(item)
            }
            // Add saved items
            for savedItem in savedRoom.items {
                if let item = createItem(from: savedItem) {
                    room.addItem(item)
                }
            }
            // Restore door locks
            for (direction, savedDoor) in savedRoom.doors {
                if room.hasDoor(in: direction) {
                    var door = room.getDoor(in: direction)!
                    door.setLocked(savedDoor.isLocked)
                }
            }
        }

        // Restore player
        let playerRoom = roomMap[savedGame.player.currentRoomKey] ?? startRoom
        let player = Player(startingRoom: playerRoom)
        player.setMaxWeight(savedGame.player.maxWeight)
        player.setCurrentWeight(savedGame.player.currentWeight)

        // Restore inventory
        for savedItem in savedGame.player.inventory {
            if let item = createItem(from: savedItem) {
                player.appendItem(item)
            }
        }

        // Restore history
        for key in savedGame.player.historyKeys {
            if let room = roomMap[key] {
                player.pushHistory(room)
            }
        }

        // Restore moving characters
        var restoredMovingChars = [MovingCharacter]()
        for savedChar in savedGame.movingCharacters {
            guard let room = roomMap[savedChar.currentRoomKey],
                  let strategy = MovementStrategy(rawValue: savedChar.strategy) else { continue }
            // Create a fresh moving character with the same name/description
            let character = MovingCharacter(
                nameKey: savedChar.nameKey,
                descriptionKey: "\(savedChar.nameKey)_desc",
                currentRoom: room,
                strategy: strategy
            )
            if strategy == .followPath, let pathKeys = savedChar.pathKeys {
                let path = pathKeys.compactMap { roomMap[$0] }
                character.setPath(path)
                if let index = savedChar.pathIndex {
                    character.setPathIndex(index)
                }
            }
            // If it's the stalker, set target player (handled later)
            if savedChar.nameKey == "character_stalker" {
                character.setTargetPlayer(player)
            }
            restoredMovingChars.append(character)
        }

        // Replace engine's internal state
        gameEngine.replaceWith(
            player: player,
            allRooms: allRooms,
            movingCharacters: restoredMovingChars,
            timeLeft: savedGame.timeLeft
        )

        gameEngine.log("Game loaded from '\(name)'")
        return true
    }

    // MARK: - Helpers

    private static func savedItem(from item: Item) -> SavedItem {
        var isBeamerCharged: Bool?
        var beamerRoomKey: String?
        var torchBattery: Int?
        var divingSuitOxygen: Int?

        if let beamer = item as? Beamer {
            isBeamerCharged = beamer.isCharged
            beamerRoomKey = beamer.memorizedRoom?.key
        } else if let torch = item as? Torch {
            torchBattery = torch.batteryLife
        } else if let suit = item as? DivingSuit {
            divingSuitOxygen = suit.oxygenLevel
        }

        return SavedItem(
            type: item.type.rawValue,
            isBeamerCharged: isBeamerCharged,
            beamerRoomKey: beamerRoomKey,
            torchBattery: torchBattery,
            divingSuitOxygen: divingSuitOxygen
        )
    }

    private static func createItem(from saved: SavedItem) -> Item? {
        guard let type = ItemType(rawValue: saved.type) else { return nil }
        let item = type.createItem()

        if let beamer = item as? Beamer {
            if let charged = saved.isBeamerCharged, charged, let roomKey = saved.beamerRoomKey {
                beamer.forceCharge(roomKey: roomKey)
            }
        } else if let torch = item as? Torch, let battery = saved.torchBattery {
            torch.setBatteryLife(battery)
        } else if let suit = item as? DivingSuit, let oxygen = saved.divingSuitOxygen {
            suit.setOxygenLevel(oxygen)
        }
        return item
    }

    private static func collectAllRooms(from start: Room) -> [Room] {
        var visited = Set<Room>()
        var result = [Room]()
        var queue = [start]
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if visited.contains(current) { continue }
            visited.insert(current)
            result.append(current)
            for direction in Direction.allCases.map({ $0.rawValue }) {
                if let neighbor = current.getExit(direction) {
                    queue.append(neighbor)
                }
            }
        }
        return result
    }
}
