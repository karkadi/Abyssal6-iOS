//
//  GenericItem.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - GenericItem (simple items without extra state)

final class GenericItem: Item {
    override var information: String { name }
}

