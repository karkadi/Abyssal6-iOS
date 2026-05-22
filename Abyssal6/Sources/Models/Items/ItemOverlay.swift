//
//  ItemOverlay.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 21/05/2026.
//
import Foundation

struct ItemOverlay: Identifiable {
    let id: UUID
    let nameKey: String
    let imageName: String
    let type: ItemOverlayType
    var alpha: Double = 0.0

    enum ItemOverlayType {
        case roomItem
        case inventory
    }
}
