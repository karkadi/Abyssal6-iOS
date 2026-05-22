//
//  Room.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

// MARK: - Room Class

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

    var exitString: String {
        let directions = exits.keys.sorted().map { direction in
            var output = Lang.string(direction)
            if trapDoors.contains(direction) { output += "⚠️" }
            if isDoorLocked(direction) { output += "🔒" }
            return output
        }
        return Lang.string("exits") + " " + directions.joined(separator: " ")
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
        let nonPlayerChars = characters
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
        return !characters.isEmpty
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

    // MARK: - Static Room Creation
    static func createRooms() -> (Room, [MovingCharacter]) {
        // Same as your existing createRooms() method.
        // (Already provided in the stub, so we reuse it)
        // This is the exact same code you wrote.
        let sas = Room(key: "room_sas", imageName: "sas.gif")
        let posteGarde = Room(key: "room_posteGarde", imageName: "poste.gif")
        let serre = Room(key: "room_serre", imageName: "serre.gif")
        let labo = Room(key: "room_labo", imageName: "labo.gif")
        let dortoir = Room(key: "room_dortoir", imageName: "dortoir.gif")
        let infirmerie = Room(key: "room_infirmerie", imageName: "infirmerie.gif")
        let machines = Room(key: "room_machines", imageName: "machines.gif")
        let reacteur = Room(key: "room_reacteur", imageName: "win.gif")
        let observation = Room(key: "room_obs", imageName: "obs.gif")
        let hydroponics = Room(key: "room_hydro", imageName: "hydro.gif")
        let engine = Room(key: "room_eng", imageName: "engine.gif")
        let airlock = Room(key: "room_air", imageName: "airlock.gif")
        let medbay = Room(key: "room_med", imageName: "medbay.gif")
        let transporter = TransporterRoom(key: "room_transporter", imageName: "transporter.gif")

        sas.setExit("north", to: airlock)
        sas.setExit("up", to: transporter)
        transporter.setExit("down", to: sas)
        airlock.setExit("south", to: sas)
        airlock.setExit("north", to: posteGarde)
        airlock.setExit("up", to: dortoir)
        airlock.addItem(ItemType.beamer.createItem())

        posteGarde.setExit("south", to: airlock)
        posteGarde.setExit("east", to: labo)
        posteGarde.setExit("north", to: medbay)

        medbay.setExit("south", to: posteGarde)
        medbay.setExit("west", to: serre)

        serre.setExit("east", to: medbay)
        serre.setLockedDoor(direction: "east", id: "door_serre", requiredKey: .blueCard, initiallyLocked: true, autoLock: false)

        labo.setExit("west", to: posteGarde)
        labo.setExit("down", to: engine)
        labo.setLockedDoor(direction: "down", id: "door_labo_down", requiredKey: .divingSuit, initiallyLocked: true, autoLock: true)

        engine.setExit("up", to: labo)
        engine.setExit("east", to: machines)
        engine.setLockedDoor(direction: "east", id: "door_engine_machines", requiredKey: .redCard, initiallyLocked: true, autoLock: false)
        engine.addItem(ItemType.wrench.createItem())

        dortoir.setExit("east", to: infirmerie)
        dortoir.setTrapDoor("east")
        dortoir.setExit("down", to: airlock)
        dortoir.setExit("north", to: observation)

        infirmerie.setExit("north", to: hydroponics)

        observation.setExit("south", to: dortoir)
        observation.setExit("east", to: hydroponics)
        observation.addItem(ItemType.torch.createItem())

        hydroponics.setExit("west", to: observation)
        hydroponics.addItem(ItemType.genetic.createItem())

        machines.setExit("north", to: reacteur)
        machines.setExit("west", to: engine)
        machines.setLockedDoor(direction: "north", id: "door_machines", requiredKey: .wrench, initiallyLocked: true, autoLock: false)

        let allRooms: [Room] = [sas, posteGarde, serre, labo, dortoir, infirmerie, machines,
                                observation, hydroponics, engine, airlock, medbay, transporter]
        transporter.initializeDestinations(allRooms)

        // Create characters (use StaticCharacter for static, MovingCharacter for moving)
        StaticCharacter(nameKey: "character_scientist", descriptionKey: "character_scientist_desc", currentRoom: labo)
            .setGreeting("character_scientist_greeting")
            .addExchange(givenType: .beamer, receivedItem: ItemType.oxygen.createItem(), messageKey: "character_scientist_exchange")

        StaticCharacter(nameKey: "character_doctor", descriptionKey: "character_doctor_desc", currentRoom: medbay)
            .setGreeting("character_doctor_greeting")
            .addExchange(givenType: .oxygen, receivedItem: ItemType.magicCookie.createItem(), messageKey: "character_doctor_exchange")

        StaticCharacter(nameKey: "character_guard", descriptionKey: "character_guard_desc", currentRoom: posteGarde)
            .setGreeting("character_guard_greeting")
            .addExchange(givenType: .torch, receivedItem: ItemType.blueCard.createItem(), messageKey: "character_guard_exchange")

        StaticCharacter(nameKey: "character_engineer", descriptionKey: "character_engineer_desc", currentRoom: serre)
            .setGreeting("character_engineer_greeting")
            .addExchange(givenType: .genetic, receivedItem: ItemType.divingSuit.createItem(), messageKey: "character_engineer_exchange")

        StaticCharacter(nameKey: "character_nurse", descriptionKey: "character_nurse_desc", currentRoom: infirmerie)
            .setGreeting("character_nurse_greeting")
            .addExchange(givenType: .blueCard, receivedItem: ItemType.firstAid.createItem(), messageKey: "character_nurse_exchange")

        StaticCharacter(nameKey: "character_geneticist", descriptionKey: "character_geneticist_desc", currentRoom: hydroponics)
            .setGreeting("character_geneticist_greeting")
            .addExchange(givenType: .firstAid, receivedItem: ItemType.redCard.createItem(), messageKey: "character_geneticist_exchange")

        let tech = MovingCharacter(nameKey: "character_wandering_tech", descriptionKey: "character_wandering_tech_desc",
                                   currentRoom: hydroponics, strategy: .random)
            .setGreeting("character_wandering_tech_greeting")
            .addItemResponse(item: ItemType.wrench.createItem(), responseKey: "character_wandering_tech_wrench")

        let path: [Room] = [sas, airlock, dortoir, infirmerie, hydroponics, observation]
        let researcher = MovingCharacter(nameKey: "character_researcher", descriptionKey: "character_researcher_desc",
                                         currentRoom: sas, strategy: .followPath)
            .setPath(path)
            .setGreeting("character_researcher_greeting")
            .addItemResponse(item: ItemType.wrench.createItem(), responseKey: "character_wandering_tech_wrench")

        let shadow = MovingCharacter(nameKey: "character_stalker", descriptionKey: "character_stalker_desc",
                                     currentRoom: serre, strategy: .followPlayer)
            .setGreeting("character_stalker_greeting")

        return (sas, [shadow, tech, researcher] )
    }
}
