//
//  GameError.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - Game Errors
enum GameError: Error, LocalizedError {
    case itemNotFound
    case itemNotPickable
    case tooHeavy

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return Lang.string("error_item_not_found")
        case .itemNotPickable:
            return Lang.string("error_item_not_pickable")
        case .tooHeavy:
            return Lang.string("error_too_heavy")
        }
    }

    var resourceKey: String {
        switch self {
        case .itemNotFound: return "error_item_not_found"
        case .itemNotPickable: return "error_item_not_pickable"
        case .tooHeavy: return "error_too_heavy"
        }
    }
}
