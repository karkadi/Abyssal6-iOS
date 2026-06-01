//
//  Player.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation
import DIContainer

/// The player character – holds inventory, weight limit, room history, and game engine reference.
final class Player: Identifiable {
    let id = UUID()
    private(set) var currentRoom: Room
    private(set) var inventory: [Item] = []
    private(set) var maxWeight: Int = 13000      // grams
    private(set) var currentWeight: Int = 0
    private var roomHistory: [Room] = []         // last element is the current room

    @ObservationIgnored
    @Injected(\.engine) private var engine: GameEngineProtocol

    // MARK: - Initialization
    init(startingRoom: Room) {
        self.currentRoom = startingRoom
        roomHistory.append(startingRoom)
    }

    // MARK: - Inventory Management
    func takeItem(_ itemName: String) throws -> Item {
        guard let item = currentRoom.removeItem(named: itemName) else {
            throw GameError.itemNotFound
        }
        guard item.canBePickedUp else {
            currentRoom.addItem(item)   // put it back
            throw GameError.itemNotPickable
        }
        guard currentWeight + item.weight <= maxWeight else {
            currentRoom.addItem(item)   // put it back
            throw GameError.tooHeavy
        }
        inventory.append(item)
        currentWeight += item.weight
        engine.refreshInventory()
        return item
    }

    func appendItem(_ item: Item) {
        inventory.append(item)
        currentWeight += item.weight
        engine.refreshInventory()
    }

    @discardableResult
    func dropItem(_ itemName: String) -> Item? {
        guard let index = inventory.firstIndex(where: { $0.name == itemName }) else {
            return nil
        }
        let item = inventory.remove(at: index)
        currentWeight -= item.weight
        currentRoom.addItem(item)
        engine.refreshInventory()
        return item
    }

    @discardableResult
    func eatItem(_ itemName: String) -> Item? {
        guard let index = inventory.firstIndex(where: { $0.name == itemName }) else {
            return nil
        }
        let item = inventory.remove(at: index)
        currentWeight -= item.weight
        engine.refreshInventory()
        return item
    }

    // MARK: - Inventory Queries
    func hasItem(named itemName: String) -> Bool {
        return inventory.contains { $0.name == itemName }
    }

    func getInventoryDescription() -> String {
        guard !inventory.isEmpty else {
            return Lang.string("inventory_empty")
        }
        var desc = Lang.string("inventory")
        for item in inventory {
            desc += " " + item.information
        }
        desc += "\n" + weightString
        return desc
    }

    var weightString: String {
        return String(format: Lang.string("total_weight"),
                      Double(currentWeight) / 1000.0,
                      Double(maxWeight) / 1000.0)
    }

    // MARK: - Item Exchange (used by GiveCommand)
    @discardableResult
    func exchangeItems(given givenItem: Item, received receivedItem: Item) throws -> Bool {
        guard let index = inventory.firstIndex(where: { $0.id == givenItem.id }) else {
            return false
        }
        let newWeight = currentWeight - givenItem.weight + receivedItem.weight
        guard newWeight <= maxWeight else {
            throw GameError.tooHeavy
        }
        // Remove given, add received
        inventory.remove(at: index)
        currentWeight -= givenItem.weight
        inventory.append(receivedItem)
        currentWeight += receivedItem.weight
        engine.refreshInventory()
        return true
    }

    func findBeamerInInventory() -> Beamer? {
        return inventory.first(where: { $0 is Beamer }) as? Beamer
    }

    // MARK: - Room History
    func pushHistory() {
        roomHistory.append(currentRoom)
    }

    func pushHistory(_ room: Room) {
        // Used during restore – add without checking current room
        roomHistory.append(room)
    }

    func goBack() -> Bool {
        guard roomHistory.count > 1 else { return false }
        let previousRoom = roomHistory[roomHistory.count - 2]
        guard currentRoom.isExit(previousRoom) else { return false }
        roomHistory.removeLast()
        currentRoom = previousRoom
        engine.setPlayerRoom(currentRoom)
        return true
    }

    var previousRoom: Room? {
        guard roomHistory.count >= 2 else { return nil }
        return roomHistory[roomHistory.count - 2]
    }

    var history: [Room] {
        return roomHistory
    }

    var historySize: Int {
        return roomHistory.count
    }

    // MARK: - Setters for Restoration
    func setMaxWeight(_ newMax: Int) {
        maxWeight = newMax
    }

    func getMaxWeight() -> Int {
        return maxWeight
    }

    func setCurrentWeight(_ newWeight: Int) {
        currentWeight = newWeight
    }

    func getCurrentWeight() -> Int {
        return currentWeight
    }

    func setCurrentRoom(_ room: Room) {
        currentRoom = room
    }

    // MARK: - Utility
    func clearInventory() {
        inventory.removeAll()
        currentWeight = 0
    }
}
