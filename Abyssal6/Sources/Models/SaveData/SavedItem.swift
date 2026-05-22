//
//  SavedItem.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

struct SavedItem: Codable {
    let type: String       // ItemType rawValue
    let isBeamerCharged: Bool?
    let beamerRoomKey: String?
    let torchBattery: Int?
    let divingSuitOxygen: Int?
    // MagicCookie has no extra state
}
