//
//  CharacterOverlay.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

// MARK: - Overlay Types

struct CharacterOverlay: Identifiable {
    let id = UUID()
    let nameKey: String
    let imageName: String
    var alpha: Double = 0.0
}
