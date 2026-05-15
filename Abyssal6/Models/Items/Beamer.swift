//
//  Beamer.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - Beamer (teleporter with charge and memorized room)

final class Beamer: Item {
    private var memorizedRoomKey: String?
    private(set) var isCharged: Bool = false
    
    var memorizedRoom: Room? {
        guard let key = memorizedRoomKey else { return nil }
        // Resolve room from game world (needs a reference to the room map).
        // This is a weak reference; we'll set it via a method.
        return GameWorld.shared.room(forKey: key)
    }
    
    override var information: String {
        if isCharged, let room = memorizedRoom {
            return String(format: Lang.string("beamer_charged_format"), name, room.shortDescription)
        } else {
            return String(format: Lang.string("beamer_discharged_format"), name)
        }
    }
    
    func charge(with room: Room) {
        memorizedRoomKey = room.key
        isCharged = true
    }
    
    func fire() -> Room? {
        guard isCharged, let room = memorizedRoom else { return nil }
        // Reset after use
        memorizedRoomKey = nil
        isCharged = false
        return room
    }
    
    /// For loading saved games – directly set the state.
    func forceCharge(roomKey: String) {
        memorizedRoomKey = roomKey
        isCharged = true
    }
    
    override func copy() -> Item {
        let newBeamer = Beamer(type: .beamer)
        if isCharged, let key = memorizedRoomKey {
            newBeamer.forceCharge(roomKey: key)
        }
        return newBeamer
    }
}

