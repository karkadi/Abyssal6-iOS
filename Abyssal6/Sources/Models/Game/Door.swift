//
//  Door.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

// MARK: - Door Struct (immutable, replaced on changes)

struct Door {
    let id: String
    let requiredKey: ItemType
    var isLocked: Bool
    let autoLock: Bool

    mutating func setLocked(_ locked: Bool) {
        self.isLocked = locked
    }
}
