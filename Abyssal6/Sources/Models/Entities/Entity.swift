//
//  Entity.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//

// MARK: - Entity Protocol (common for Player and StaticCharacter)

protocol Entity: AnyObject {
    var nameKey: String { get }
    var descriptionKey: String { get }
    var currentRoom: Room { get set }
    var fullDescription: String { get }
}

extension Entity {
    var localizedName: String { Lang.string(nameKey) }
    var localizedDescription: String { Lang.string(descriptionKey) }
    // Note: descriptionKey is not defined here; each entity will provide its own.
}
