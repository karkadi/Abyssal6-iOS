//
//  Torch.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - Torch (with battery life)

final class Torch: Item {
    private(set) var batteryLife: Int = 100   // percentage

    override var information: String {
        "\(name) \(batteryLife)%"
    }

    func setBatteryLife(_ value: Int) {
        batteryLife = max(0, min(100, value))
    }

    override func copy() -> Item {
        let newTorch = Torch(type: .torch)
        newTorch.setBatteryLife(batteryLife)
        return newTorch
    }
}
