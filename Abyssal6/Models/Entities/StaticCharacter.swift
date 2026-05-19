//
//  StaticCharacter.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

// MARK: - StaticCharacter Class

@Observable
class StaticCharacter: Identifiable, Entity {
    let id = UUID()
    let nameKey: String
    let descriptionKey: String
    var currentRoom: Room

    // Greeting & spoken flag
    private var greetingKey: String?
    private var hasSpoken = false

    // Item responses (item name -> response key)
    private var itemResponses: [String: String] = [:]

    // Help item (required item + help message)
    private var requiredItem: Item?
    private var helpMessageKey: String?
    private var helpGiven = false

    // Exchanges (given ItemType -> received Item)
    var exchangeItems: [ItemType: Item] = [:]
    private var exchangeMessageKey: String?

    // MARK: - Initialization
    init(nameKey: String, descriptionKey: String, currentRoom: Room) {
        self.nameKey = nameKey
        self.descriptionKey = descriptionKey
        self.currentRoom = currentRoom
        currentRoom.addCharacter(self)
    }

    func setCurrentRoom(_ newRoom: Room) {
        let oldRoom = self.currentRoom
        guard oldRoom !== newRoom else { return }
        oldRoom.removeCharacter(self)   // remove from old room
        self.currentRoom = newRoom
        newRoom.addCharacter(self)      // add to new room
    }

    // MARK: - Fluent Builders
    @discardableResult
    func setGreeting(_ key: String) -> Self {
        greetingKey = key
        return self
    }

    @discardableResult
    func addItemResponse(item: Item, responseKey: String) -> Self {
        itemResponses[item.name] = responseKey
        return self
    }

    @discardableResult
    func setHelpItem(_ item: Item, helpMessageKey: String) -> Self {
        requiredItem = item
        self.helpMessageKey = helpMessageKey
        return self
    }

    @discardableResult
    func addExchange(givenType: ItemType, receivedItem: Item, messageKey: String) -> Self {
        exchangeItems[givenType] = receivedItem
        exchangeMessageKey = messageKey
        return self
    }

    // MARK: - Description
    var fullDescription: String {
        var desc = String(format: Lang.string("character_description_format"),
                          localizedName, localizedDescription)
        if let greeting = greetingKey, !hasSpoken {
            desc += String(format: Lang.string("character_greeting_format"),
                           Lang.string(greeting))
            hasSpoken = true
        }
        return desc
    }

    // MARK: - Speech
    func speak() -> String {
        var message: String
        if let greeting = greetingKey {
            message = String(format: Lang.string("character_speak_format"),
                             localizedName, Lang.string(greeting))
        } else {
            message = String(format: Lang.string("character_speak_no_greeting_format"),
                             localizedName)
        }

        if let exchangeMsg = exchangeMessageKey, !exchangeItems.isEmpty {
            message += "\n" + String(format: Lang.string("character_exchange_offer_format"),
                                     localizedName, Lang.string(exchangeMsg))
        }
        return message
    }

    // MARK: - Item Interaction
    func reactToItem(_ item: Item) -> String? {
        // Check exchange first
        if acceptsExchange(item) {
            return String(format: Lang.string("character_exchange_offer_format"),
                          localizedName, Lang.string(exchangeMessageKey ?? ""))
        }

        // Check specific item responses
        if let responseKey = itemResponses[item.name] {
            return String(format: Lang.string("character_response_format"),
                          localizedName, Lang.string(responseKey))
        }

        // Check help item
        if !helpGiven, let required = requiredItem, required.type == item.type {
            helpGiven = true
            return String(format: Lang.string("character_help_format"),
                          localizedName, Lang.string(helpMessageKey ?? ""))
        }

        return nil
    }

    // MARK: - Exchanges
    func acceptsExchange(_ item: Item) -> Bool {
        return exchangeItems.keys.contains(item.type)
    }

    func performExchange(given item: Item) -> Item? {
        guard let received = exchangeItems[item.type] else { return nil }
        return received.copy()
    }

    // MARK: - Getters / Setters for Restoration
    var helpGivenFlag: Bool {
        get { helpGiven }
        set { helpGiven = newValue }
    }

    func getRequiredItem() -> Item? { requiredItem }
}
