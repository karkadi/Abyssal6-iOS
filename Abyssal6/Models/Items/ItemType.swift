//
//  ItemType.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

// MARK: - ItemType Enum

enum ItemType: String, CaseIterable {
    case divingSuit = "diving_suit"
    case torch = "torch"
    case blueCard = "blue_card"
    case redCard = "red_card"
    case wrench = "wrench"
    case genetic = "genetic"
    case oxygen = "oxygen"
    case firstAid = "firstaid"
    case magicCookie = "magic_cookie"
    case beamer = "beamer"
    
    // Localization keys
    var nameKey: String { "item_\(rawValue)" }
    var imageName: String { "item_\(rawValue)" }
    
    // Physical properties (in grams)
    var weight: Int {
        switch self {
        case .divingSuit: return 19000
        case .torch: return 1300
        case .blueCard, .redCard: return 100
        case .wrench: return 1200
        case .genetic: return 300
        case .oxygen: return 3000
        case .firstAid: return 2100
        case .magicCookie: return 1100
        case .beamer: return 5200
        }
    }
    
    var canBePickedUp: Bool {
        switch self {
        case .divingSuit, .torch, .blueCard, .redCard, .wrench, .genetic, .oxygen, .firstAid, .magicCookie, .beamer:
            return true
        }
    }
    
    var isUsable: Bool {
        switch self {
        case .divingSuit, .torch, .blueCard, .redCard, .wrench, .beamer:
            return true
        case .genetic, .oxygen, .firstAid, .magicCookie:
            return false
        }
    }
    
    /// Factory method to create the appropriate Item subclass.
    func createItem() -> Item {
        switch self {
        case .torch:
            return Torch(type: .torch)
        case .divingSuit:
            return DivingSuit(type: .divingSuit)
        case .magicCookie:
            return MagicCookie(type: .magicCookie)
        case .beamer:
            return Beamer(type: .beamer)
        default:
            return GenericItem(type: self)
        }
    }
}

