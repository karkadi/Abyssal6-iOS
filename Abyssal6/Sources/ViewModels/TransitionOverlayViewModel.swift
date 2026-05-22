//
//  TransitionOverlayViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI
import DIContainer

// MARK: - ViewModel for the Overlay View

@Observable
@MainActor
final class TransitionOverlayViewModel {
    var backgroundImageName: String = ""
    private(set) var characterOverlays: [CharacterOverlay] = []
    private(set) var roomItemOverlays: [ItemOverlay] = []
    private(set) var inventoryOverlays: [ItemOverlay] = []
    var transitioningToNewImage = false
    private var backgroundTask: Task<Void, Never>?

    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol

    var calloutCharacter: StaticCharacter?
    private var calloutQueue: [StaticCharacter] = []

    // Show a single callout, queueing if another is already displayed
    func showCharacterCallout(_ character: StaticCharacter) {
        if calloutCharacter != nil {
            calloutQueue.append(character)
            return
        }
        calloutCharacter = character
        // Dismiss after display duration (handled by the view itself)
    }

    // Called by the view when the current callout disappears
    func dismissCallout() {
        calloutCharacter = nil
        if !calloutQueue.isEmpty {
            let next = calloutQueue.removeFirst()
            showCharacterCallout(next)
        }
    }

    // Show callouts for all static (non‑moving) characters in the current room
    func showCalloutsForCurrentRoom() {
        let characters = player.currentRoom.characters
        // Filter out moving characters (they have their own intro logic)
        let staticChars = characters.filter { !($0 is MovingCharacter) }
        for character in staticChars {
            showCharacterCallout(character)
        }
    }

    var player: Player {
        return engine.player
    }

    func showItemDetails(_ item: Item) {
        engine.showItemDetails(item)
    }

    // MARK: - Background Transition
    func setBackground(imageName: String, animated: Bool = true) {
        if backgroundTask != nil {
            print("DEBUG: Cancelling previous room image task!")
        }
        backgroundTask?.cancel()
        backgroundTask = nil

        if animated && !backgroundImageName.isEmpty {
            transitioningToNewImage = true
            withAnimation(.easeInOut(duration: 1.0)) {
                backgroundImageName = imageName
            }

            backgroundTask = Task {
                try? await Task.sleep(for: .seconds(1.0))

                guard !Task.isCancelled else {
                    print("DEBUG: Task cancellation successfully caught. Dropping stale room update.")
                    return
                }

                self.transitioningToNewImage = false
                self.backgroundTask = nil
                print("DEBUG: Successfully completed room transition image swap.")
            }
        } else {
            backgroundImageName = imageName
            transitioningToNewImage = false
        }
    }

    // MARK: - Overlay Management
    func addCharacterOverlay(nameKey: String, imageName: String) {
        // Prevent double overlays for the same character
        guard !characterOverlays.contains(where: { $0.nameKey == nameKey }) else { return }
        let newOverlay = CharacterOverlay(nameKey: nameKey, imageName: imageName)
        characterOverlays.append(newOverlay)
        // Fade in
        withAnimation(.easeIn(duration: 0.3)) {
            if let index = characterOverlays.firstIndex(where: { $0.id == newOverlay.id }) {
                characterOverlays[index].alpha = 0.9
            }
        }
    }

    func removeCharacterOverlay(nameKey: String) {
        characterOverlays.removeAll { $0.nameKey == nameKey }
    }

    func removeRoomItemOverlay(nameKey: String) {
        roomItemOverlays.removeAll { $0.nameKey == nameKey }
    }

    func addRoomItemOverlay(id: UUID, nameKey: String, imageName: String) {
        let newOverlay = ItemOverlay(id: id, nameKey: nameKey, imageName: imageName, type: .roomItem)
        roomItemOverlays.append(newOverlay)
        withAnimation(.easeIn(duration: 0.3)) {
            if let index = roomItemOverlays.firstIndex(where: { $0.id == newOverlay.id }) {
                roomItemOverlays[index].alpha = 0.9
            }
        }
    }

    func addInventoryOverlay(id: UUID, nameKey: String, imageName: String) {
        let newOverlay = ItemOverlay(id: id, nameKey: nameKey, imageName: imageName, type: .inventory)
        inventoryOverlays.append(newOverlay)
        withAnimation(.easeIn(duration: 0.3)) {
            if let index = inventoryOverlays.firstIndex(where: { $0.id == newOverlay.id }) {
                inventoryOverlays[index].alpha = 0.9
            }
        }
    }

    func removeInventoryOverlay(nameKey: String) {
        inventoryOverlays.removeAll { $0.nameKey == nameKey }
    }

    func clearInventoryOverlays() {
        inventoryOverlays.removeAll()
    }

    func clearAllOverlays() {
        withAnimation(.easeOut(duration: 0.2)) {
            characterOverlays.removeAll()
            roomItemOverlays.removeAll()
            inventoryOverlays.removeAll()
        }
    }

    func interpretCommand(_ input: String) {
        engine.interpretCommand(input)
    }

}
