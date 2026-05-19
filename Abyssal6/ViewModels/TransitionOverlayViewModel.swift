//
//  TransitionOverlayViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI
import DIContainer

// MARK: - Overlay Types

struct CharacterOverlay: Identifiable {
    let id = UUID()
    let nameKey: String
    let imageName: String
    var alpha: Double = 0.0
}

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

// MARK: - ViewModel for the Overlay View

@Observable
final class TransitionOverlayViewModel {
    var backgroundImageName: String = ""
    private(set) var characterOverlays: [CharacterOverlay] = []
    private(set) var roomItemOverlays: [ItemOverlay] = []
    private(set) var inventoryOverlays: [ItemOverlay] = []
    private var transitioningToNewImage = false
    
    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol
    
    var player: Player {
        return engine.player
    }
    
    func showItemDetails(_ item: Item) {
        engine.showItemDetails(item)
    }
    
    // MARK: - Background Transition
    func setBackground(imageName: String, animated: Bool = true) {
        if animated && !backgroundImageName.isEmpty {
            transitioningToNewImage = true
            withAnimation(.easeInOut(duration: 1.0)) {
                backgroundImageName = imageName
            }
            
            Task { @MainActor in
                // Descriptive duration API
                try? await Task.sleep(for: .seconds(1.0))
                
                self.transitioningToNewImage = false
            }
        } else {
            backgroundImageName = imageName
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
