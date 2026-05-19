//
//  DivingSuit.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - DivingSuit (with oxygen level)

final class DivingSuit: Item {
    private(set) var oxygenLevel: Int = 60    // percentage

    override var information: String {
        "\(name) \(oxygenLevel)%"
    }

    func setOxygenLevel(_ value: Int) {
        oxygenLevel = max(0, min(100, value))
    }

    override func copy() -> Item {
        let newSuit = DivingSuit(type: .divingSuit)
        newSuit.setOxygenLevel(oxygenLevel)
        return newSuit
    }
}
