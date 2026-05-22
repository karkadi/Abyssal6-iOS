//
//  File.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

// MARK: - Notification Names
extension Notification.Name {
    static let gameStateDidChange = Notification.Name("gameStateDidChange")
    static let roomDidChange = Notification.Name("roomDidChange")
    static let inventoryDidChange = Notification.Name("inventoryDidChange")
    static let gameLog = Notification.Name("gameLog")
    static let addCharacterOverlay = Notification.Name("addCharacterOverlay")
    static let removeCharacterOverlay = Notification.Name("removeCharacterOverlay")
    static let showTalkPopup = Notification.Name("showTalkPopup")
    static let showGivePopup = Notification.Name("showGivePopup")
    static let showEasterEgg = Notification.Name("showEasterEgg")
    static let showItemDetails = Notification.Name("showItemDetails")
    static let showGiveDialog = Notification.Name("showGiveDialog")
    static let showTalkDialog = Notification.Name("showTalkDialog")
    static let timeLeftDidChange = Notification.Name("timeLeftDidChange")
}
