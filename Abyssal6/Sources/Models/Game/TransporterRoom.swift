//
//  TransporterRoom.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import Foundation

/// A special room that teleports the player to a random destination (or forced for testing).
final class TransporterRoom: Room {
    // MARK: - Properties
    private var allDestinations: [Room] = []
    private var forcedDestinationKey: String?
    private var isTestModeActive: Bool = false
    private var randomGenerator = SystemRandomNumberGenerator()

    // MARK: - Initialization
    override init(key: String, imageName: String) {
        super.init(key: key, imageName: imageName)
    }

    // MARK: - Public Methods
    /// Sets the list of possible destination rooms (must be called after all rooms are created).
    func initializeDestinations(_ rooms: [Room]) {
        allDestinations = rooms
    }

    /// Activates test mode: the next teleport will go to the room with the given key.
    func setForcedDestination(_ roomKey: String) {
        forcedDestinationKey = roomKey
        isTestModeActive = true
    }

    /// Disables test mode, returning to true random behaviour.
    func clearForcedDestination() {
        forcedDestinationKey = nil
        isTestModeActive = false
    }

    /// Returns true if test mode is currently active.
    var isTestMode: Bool { isTestModeActive }

    // MARK: - Overrides
    /// Overrides the exit lookup to provide a random destination.
    override func getExit(_ direction: String) -> Room? {
        return getRandomDestination()
    }

    /// Extended description that includes the transporter effect warning and test mode indicator.
    override var longDescription: String {
        let base = super.longDescription
        let transporterHint = Lang.string("transporter_room_description")
        var result = base + "\n" + transporterHint

        if isTestModeActive {
            let targetName: String
            if let forced = forcedDestinationKey {
                targetName = Lang.string("short_\(forced)")
            } else {
                targetName = Lang.string("random")
            }
            let testModeText = String(format: Lang.string("transporter_test_mode"), targetName)
            result += "\n" + testModeText
        }
        return result
    }

    // MARK: - Private Helpers
    private func getRandomDestination() -> Room? {
        // Test mode with forced destination
        if isTestModeActive, let forcedKey = forcedDestinationKey {
            if let room = allDestinations.first(where: { $0.key == forcedKey }) {
                return room
            }
        }

        // Normal random selection (excluding self? Java includes all rooms, even itself, but that would cause a loop.
        // To match Java exactly, we allow self; but typical game design excludes self. We'll follow Java: include all.
        guard !allDestinations.isEmpty else { return self }
        let randomIndex = Int.random(in: 0..<allDestinations.count, using: &randomGenerator)
        return allDestinations[randomIndex]
    }
}
