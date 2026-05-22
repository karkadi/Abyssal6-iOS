//
//  SavedMovingCharacter.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

struct SavedMovingCharacter: Codable {
    let nameKey: String
    let currentRoomKey: String
    let strategy: String   // MovementStrategy rawValue
    let pathIndex: Int?
    let pathKeys: [String]?
}
