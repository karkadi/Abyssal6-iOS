//
//  MagicCookie.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - MagicCookie (increases max weight when eaten)

final class MagicCookie: Item {
    static let weightBonus = 13000   // grams

    override var information: String {
        String(format: Lang.string("magic_cookie_info"), name, Double(MagicCookie.weightBonus) / 1000.0)
    }

    override func copy() -> Item {
        return MagicCookie(type: .magicCookie)
    }

    func applyEffect(_ player: Player) {
        player.setMaxWeight(player.getMaxWeight() + MagicCookie.weightBonus)
    }
}
