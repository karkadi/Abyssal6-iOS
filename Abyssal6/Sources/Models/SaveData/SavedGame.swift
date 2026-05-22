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
