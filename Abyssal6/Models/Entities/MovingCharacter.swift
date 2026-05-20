//
//  MovingCharacter.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

// MARK: - Movement Strategy Enum

enum MovementStrategy: String {
    case random
    case followPath
    case followPlayer
}

// MARK: - MovingCharacter Class

@Observable
final class MovingCharacter: StaticCharacter {
    // MARK: - Properties
    private var strategy: MovementStrategy
    private var path: [Room] = []
    private var currentPathIndex: Int = 0
    private weak var targetPlayer: Player?   // weak to avoid retain cycle

    // MARK: - Initialization
    init(nameKey: String, descriptionKey: String, currentRoom: Room, strategy: MovementStrategy = .random) {
        self.strategy = strategy
        super.init(nameKey: nameKey, descriptionKey: descriptionKey, currentRoom: currentRoom)
    }

    // MARK: - Fluent Overrides (return Self)
    @discardableResult
    override func setGreeting(_ key: String) -> Self {
        super.setGreeting(key)
        return self
    }

    @discardableResult
    override func addItemResponse(item: Item, responseKey: String) -> Self {
        super.addItemResponse(item: item, responseKey: responseKey)
        return self
    }

    @discardableResult
    override func setHelpItem(_ item: Item, helpMessageKey: String) -> Self {
        super.setHelpItem(item, helpMessageKey: helpMessageKey)
        return self
    }

    // MARK: - Strategy Configuration
    @discardableResult
    func setPath(_ path: [Room]) -> Self {
        self.path = path
        self.strategy = .followPath
        return self
    }

    func setStrategy(_ strategy: MovementStrategy) -> Self {
        self.strategy = strategy
        return self
    }

    @discardableResult
    func setTargetPlayer(_ player: Player) -> Self {
        self.targetPlayer = player
        return self
    }

    // MARK: - Movement
    func move() {
        let current = currentRoom
        let next: Room?

        switch strategy {
        case .random:
            next = getRandomAdjacentRoom(from: current)
        case .followPath:
            next = getNextPathRoom()
        case .followPlayer:
            next = getNextRoomTowardsPlayer()
        }

        if let nextRoom = next, nextRoom !== current {
            setCurrentRoom(nextRoom)
        }
    }

    // MARK: - Random Movement
    private func getRandomAdjacentRoom(from room: Room) -> Room? {
        let allDirections = Direction.allCases
        var availableExits: [Room] = []

        for dir in allDirections {
            let directionString = dir.rawValue
            if let exit = room.getExit(directionString), !room.isDoorLocked(directionString) {
                availableExits.append(exit)
            }
        }

        return availableExits.randomElement()
    }

    // MARK: - Path Following
    private func getNextPathRoom() -> Room? {
        guard !path.isEmpty else { return nil }
        let next = path[currentPathIndex]
        currentPathIndex = (currentPathIndex + 1) % path.count
        return next
    }

    // MARK: - Player Following (BFS)
    private func getNextRoomTowardsPlayer() -> Room? {
        guard let player = targetPlayer else { return nil }
        let playerRoom = player.currentRoom
        let current = currentRoom

        if playerRoom == current { return nil }

        return findPathTowards(target: playerRoom, from: current)
    }

    private func findPathTowards(target: Room, from start: Room) -> Room? {
        // BFS
        var queue: [Room] = [start]
        var cameFrom: [Room: Room] = [start: start]
        var visited: Set<Room> = [start]

        while !queue.isEmpty {
            let current = queue.removeFirst()

            if current === target {
                return reconstructFirstStep(cameFrom: cameFrom, start: start, target: target)
            }

            for direction in Direction.allCases {
                let dirString = direction.rawValue
                guard let neighbor = current.getExit(dirString),
                      !visited.contains(neighbor),
                      !current.isDoorLocked(dirString) else {
                    continue
                }
                visited.insert(neighbor)
                cameFrom[neighbor] = current
                queue.append(neighbor)
            }
        }

        // No path found -> fallback to random movement
        return getRandomAdjacentRoom(from: start)
    }

    private func reconstructFirstStep(cameFrom: [Room: Room], start: Room, target: Room) -> Room? {
        var step = target
        while let prev = cameFrom[step], prev != start {
            step = prev
        }
        return step === start ? nil : step
    }

    // MARK: - Override Description
    override var fullDescription: String {
        var desc = super.fullDescription
        let strategyDesc: String
        switch strategy {
        case .random:
            strategyDesc = Lang.string("moving_strategy_random")
        case .followPath:
            strategyDesc = Lang.string("moving_strategy_path")
        case .followPlayer:
            strategyDesc = Lang.string("moving_strategy_player")
        }
        if !strategyDesc.isEmpty {
            desc += "\n  " + strategyDesc
        }
        return desc
    }

    // MARK: - Restoration Helpers
    func getStrategy() -> MovementStrategy { strategy }
    func getPath() -> [Room] { path }
    func getPathIndex() -> Int { currentPathIndex }
    func setPathIndex(_ index: Int) {
        guard !path.isEmpty else { return }
        currentPathIndex = index % path.count
    }
}

// MARK: - Direction Enum (for completeness)

enum Direction: String, CaseIterable {
    case north, south, east, west, up, down
}
