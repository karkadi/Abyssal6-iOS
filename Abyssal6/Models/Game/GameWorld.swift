//
//  GameWorld.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import Foundation

// MARK: - GameWorld Singleton (to resolve rooms for Beamer)

/// A simple registry to resolve room keys to Room objects.
/// This avoids strong reference cycles. Set up during game initialization.
final class GameWorld {
    static let shared = GameWorld()
    private var roomMap: [String: Room] = [:]
    
    func registerRoom(_ room: Room) {
        roomMap[room.key] = room
    }
    
    func room(forKey key: String) -> Room? {
        return roomMap[key]
    }
    
    func clear() {
        roomMap.removeAll()
    }
}
