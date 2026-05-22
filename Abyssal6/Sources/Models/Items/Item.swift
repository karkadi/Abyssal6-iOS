//
//  Item.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 16/05/2026.
//
import Foundation

// MARK: - Base Item Class
class Item: Identifiable {
    let id = UUID()
    let type: ItemType

    init(type: ItemType) {
        self.type = type
    }

    var name: String { type.nameKey }
    var imageName: String { type.imageName }
    var weight: Int { type.weight }
    var canBePickedUp: Bool { type.canBePickedUp }
    var isUsable: Bool { type.isUsable }

    /// Returns a displayable description (name + extra info).
    var information: String { name }

    /// Creates a copy of the item for exchanges.
    func copy() -> Item {
        // Default creates a new instance of the same type.
        // Subclasses override to copy their state.
        return type.createItem()
    }
}
