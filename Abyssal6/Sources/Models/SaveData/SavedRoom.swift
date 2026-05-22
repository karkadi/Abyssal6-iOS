//
//  SavedRoom.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

struct SavedRoom: Codable {
    var doors: [String: SavedDoor]
    var items: [SavedItem]
}
