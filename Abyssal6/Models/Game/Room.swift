//
//  Room.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

// MARK: - Door Struct (immutable, replaced on changes)

struct Door {
    let id: String
    let requiredKey: ItemType
    var isLocked: Bool
    let autoLock: Bool
}

// MARK: - Room Class

@Observable
class Room: Identifiable, Hashable {
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    let key: String
    let imageName: String

    private(set) var exits: [String: Room] = [:]
    private(set) var items: [Item] = []
    private(set) var characters: [StaticCharacter] = []
    private var doors: [String: Door] = [:]
    private var trapDoors: Set<String> = []

    // MARK: - Initialization
    init(key: String, imageName: String) {
        self.key = key
        self.imageName = imageName
        GameWorld.shared.registerRoom(self)
    }

    // MARK: - Localized Descriptions
    var shortDescription: String {
        Lang.string("short_\(key)")
    }

    var longDescription: String {
        var desc = Lang.string(key) + "\n"
        desc += exitString + "\n"
        desc += itemString
        desc += entityString
        if !trapDoors.isEmpty {
            desc += "\n" + Lang.string("trapdoor_warning")
        }
        return desc
    }

    private var exitString: String {
        var result = Lang.string("exits")
        for direction in exits.keys.sorted() {
            result += " " + Lang.string(direction)
            if trapDoors.contains(direction) {
                result += "⚠️"
            }
            if isDoorLocked(direction) {
                result += " 🔒"
            }
        }
        return result
    }

    private var itemString: String {
        guard !items.isEmpty else { return "" }
        var result = Lang.string("found_item")
        for item in items {
            result += " " + item.information
        }
        return result + ".\n"
    }

    private var entityString: String {
        let nonPlayerChars = characters.filter { !($0 is Player) }
        guard !nonPlayerChars.isEmpty else { return "" }
        var result = "\n" + Lang.string("presences")
        for char in nonPlayerChars {
            result += "\n  • " + char.fullDescription
        }
        return result
    }

    // MARK: - Exits Management
    func setExit(_ direction: String, to room: Room) {
        exits[direction] = room
    }

    func getExit(_ direction: String) -> Room? {
        return exits[direction]
    }

    func isExit(_ room: Room) -> Bool {
        return exits.values.contains { $0 === room }
    }

    // MARK: - Items Management
    func addItem(_ item: Item) {
        items.append(item)
    }

    @discardableResult
    func removeItem(_ item: Item) -> Bool {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            return true
        }
        return false
    }

    func removeItem(named name: String) -> Item? {
        if let index = items.firstIndex(where: { $0.name == name }) {
            let item = items[index]
            items.remove(at: index)
            return item
        }
        return nil
    }

    func containsItem(named name: String) -> Bool {
        return items.contains { $0.name == name }
    }

    func getItem(named name: String) -> Item? {
        return items.first { $0.name == name }
    }

    // MARK: - Characters Management
    func addCharacter(_ character: StaticCharacter) {
        guard !characters.contains(where: { $0.id == character.id }) else { return }
           characters.append(character)
    }

    func removeCharacter(_ character: StaticCharacter) {
        characters.removeAll { $0.id == character.id }
    }

    func getCharacter(named nameKey: String) -> StaticCharacter? {
        return characters.first { $0.nameKey == nameKey }
    }

    var hasCharacters: Bool {
        return characters.contains { !($0 is Player) }
    }

    // MARK: - Doors Management
    func setLockedDoor(direction: String, id: String, requiredKey: ItemType, initiallyLocked: Bool, autoLock: Bool) {
        guard exits[direction] != nil else { return }
        doors[direction] = Door(id: id, requiredKey: requiredKey, isLocked: initiallyLocked, autoLock: autoLock)
    }

    func hasDoor(in direction: String) -> Bool {
        return doors[direction] != nil
    }

    func getDoor(in direction: String) -> Door? {
        return doors[direction]
    }

    func isDoorLocked(_ direction: String) -> Bool {
        return doors[direction]?.isLocked ?? false
    }

    @discardableResult
    func unlockDoor(direction: String, with key: Item) -> Bool {
        guard var door = doors[direction], door.requiredKey == key.type, door.isLocked else {
            return false
        }
        door.isLocked = false
        doors[direction] = door
        return true
    }

    @discardableResult
    func lockDoor(direction: String, with key: Item) -> Bool {
        guard var door = doors[direction], door.requiredKey == key.type, !door.isLocked else {
            return false
        }
        door.isLocked = true
        doors[direction] = door
        return true
    }

    func doorPassed(_ direction: String) {
        guard var door = doors[direction], door.autoLock else { return }
        door.isLocked = true
        doors[direction] = door
    }

    // MARK: - Trap Doors
    func setTrapDoor(_ direction: String) {
        guard exits[direction] != nil else { return }
        trapDoors.insert(direction)
    }

    func isTrapDoor(_ direction: String) -> Bool {
        return trapDoors.contains(direction)
    }

    // MARK: - Special
    var isReactor: Bool {
        return key == "room_reacteur"
    }
}
