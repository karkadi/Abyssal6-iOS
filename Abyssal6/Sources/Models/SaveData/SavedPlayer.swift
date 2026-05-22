//
//  SavedPlayer.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

struct SavedPlayer: Codable {
    let currentRoomKey: String
    let maxWeight: Int
    let currentWeight: Int
    let historyKeys: [String]
    let inventory: [SavedItem]
}
