//
//  TransitionOverlayView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

// MARK: - Main View

// MARK: - Transition Overlay View
struct TransitionOverlayView: View {
    @Binding var currentBackground: String
    @Binding var viewModel: TransitionOverlayViewModel
    
    let scaleFactor: CGFloat // Receives spatial scaling factor constraints from parent view context
    
    private let remoteImageBaseURL = "https://kazazyanalexander.github.io/Abyssale-6/images/"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background GIF
                let fullURL = "\(remoteImageBaseURL)\(viewModel.backgroundImageName)"
                GIFImage(source: fullURL)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .transition(.opacity)
                    .id(viewModel.backgroundImageName)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.backgroundImageName)
                
                // Character overlays (scaled sizes)
                ForEach(viewModel.characterOverlays) { overlay in
                    characterImageView(for: overlay)
                        .opacity(overlay.alpha)
                        .position(positionForCharacter(overlay, geometry: geometry))
                }
                
                // Room item overlays (scaled sizes)
                ForEach(viewModel.roomItemOverlays) { overlay in
                    itemImageView(for: overlay)
                        .opacity(overlay.alpha)
                        .position(positionForRoomItem(overlay, geometry: geometry))
                }
                
                // Inventory item overlays (scaled sizes)
                ForEach(viewModel.inventoryOverlays) { overlay in
                    itemImageView(for: overlay)
                        .opacity(overlay.alpha)
                        .position(positionForInventoryItem(overlay, geometry: geometry))
                }
            }
        }
        .onAppear {
            viewModel.setBackground(imageName: currentBackground)
            refreshAllOverlays()
        }
        .onChange(of: currentBackground) { _, newImage in
            viewModel.setBackground(imageName: newImage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .roomDidChange)) { notification in
            if let room = notification.object as? Room {
                viewModel.setBackground(imageName: room.imageName)
            }
            refreshAllOverlays()
        }
        .onReceive(NotificationCenter.default.publisher(for: .inventoryDidChange)) { _ in
            refreshInventoryOverlays()
        }
        .onReceive(NotificationCenter.default.publisher(for: .addCharacterOverlay)) { notification in
            if let nameKey = notification.object as? String,
               let character = findCharacter(byNameKey: nameKey) {
                viewModel.addCharacterOverlay(nameKey: nameKey, imageName: character.nameKey)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .removeCharacterOverlay)) { notification in
            if let nameKey = notification.object as? String {
                viewModel.removeCharacterOverlay(nameKey: nameKey)
            }
        }
    }
    
    // MARK: - Menu Builders
    @ViewBuilder
    private func characterContextMenu(for overlay: CharacterOverlay) -> some View {
        if let character = findCharacter(byNameKey: overlay.nameKey)  {
            Group {
                Button(Lang.string("talk_button")) {
                    viewModel.interpretCommand("talk \(character.nameKey)")
                }
                if !character.exchangeItems.isEmpty {
                    Button(Lang.string("give_button")) {
                        viewModel.interpretCommand("give")
                    }
                }
            }
        } else {
            Text(Lang.string("error_character_not_found"))
        }
    }
    
    @ViewBuilder
    private func contextMenu(for overlay: ItemOverlay) -> some View {
        if let item = findItem(byId: overlay.id, type: overlay.type) {
            Group {
                Button(Lang.string("inspect")) { viewModel.showItemDetails(item) }
                Divider()
                if overlay.type == .roomItem && item.canBePickedUp {
                    Button(Lang.string("take")) { viewModel.interpretCommand("take \(item.name)") }
                } else if overlay.type == .inventory {
                    Button(Lang.string("drop")) { viewModel.interpretCommand("drop \(item.name)") }
                    if item.isUsable {
                        Button(Lang.string("use")) { viewModel.interpretCommand("use \(item.name)") }
                    }
                    if item.type == .magicCookie {
                        Button(Lang.string("eat")) { viewModel.interpretCommand("eat \(item.name)") }
                    }
                    if let beamer = item as? Beamer {
                        Divider()
                        if !beamer.isCharged {
                            Button(Lang.string("charge")) { viewModel.interpretCommand("charge") }
                        } else {
                            Button(Lang.string("fire")) { viewModel.interpretCommand("fire") }
                        }
                    }
                }
            }
        } else {
            Text(Lang.string("error_item_not_found"))
        }
    }
    
    // MARK: - Data Refresh Helpers
    private func refreshAllOverlays() {
        viewModel.clearAllOverlays()
        loadCharactersFromCurrentRoom()
        loadRoomItemsFromCurrentRoom()
        loadInventoryItems()
    }
    
    private func refreshInventoryOverlays() {
        viewModel.clearInventoryOverlays()
        loadInventoryItems()
    }
    
    private func loadCharactersFromCurrentRoom() {
        for character in viewModel.player.currentRoom.characters {
            viewModel.addCharacterOverlay(nameKey: character.nameKey, imageName: character.nameKey)
        }
    }
    
    private func loadRoomItemsFromCurrentRoom() {
        for item in viewModel.player.currentRoom.items {
            viewModel.addRoomItemOverlay(id: item.id, nameKey: item.name, imageName: item.imageName)
        }
    }
    
    private func loadInventoryItems() {
        for item in viewModel.player.inventory {
            viewModel.addInventoryOverlay(id: item.id, nameKey: item.name, imageName: item.imageName)
        }
    }
    
    private func findCharacter(byNameKey nameKey: String) -> StaticCharacter? {
        return viewModel.player.currentRoom.characters.first { $0.nameKey == nameKey }
    }
    
    private func findItem(byId id: UUID, type: ItemOverlay.ItemOverlayType) -> Item? {
        if type == .roomItem {
            return viewModel.player.currentRoom.items.first { $0.id == id }
        } else {
            return viewModel.player.inventory.first { $0.id == id }
        }
    }
    
    // MARK: - Image Views (Applying height scales uniformly to dimensions)
    @ViewBuilder
    private func characterImageView(for overlay: CharacterOverlay) -> some View {
        Image(overlay.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 200 * scaleFactor, height: 256 * scaleFactor)
            .shadow(radius: 4 * scaleFactor)
            .contextMenu { characterContextMenu(for: overlay) }
    }
    
    @ViewBuilder
    private func itemImageView(for overlay: ItemOverlay) -> some View {
        Image(overlay.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 48 * scaleFactor, height: 48 * scaleFactor)
            .shadow(radius: 2 * scaleFactor)
            .contextMenu { contextMenu(for: overlay) }
    }
    
    // MARK: - Positioning Mathematics (Factored with respect to global bounds scale)
    private func positionForCharacter(_ overlay: CharacterOverlay, geometry: GeometryProxy) -> CGPoint {
        let count = viewModel.characterOverlays.count
        let index = viewModel.characterOverlays.firstIndex(where: { $0.id == overlay.id }) ?? 0
        
        let overlayWidth = 160 * scaleFactor
        let overlaySpacing = 10 * scaleFactor
        let rightMargin = 15 * scaleFactor
        
        let totalWidth = CGFloat(count) * overlayWidth + CGFloat(max(0, count - 1)) * overlaySpacing
        let startX = geometry.size.width - totalWidth - rightMargin
        
        let x = startX + CGFloat(index) * overlayWidth + (64 * scaleFactor)
        let y = geometry.size.height - (256 * scaleFactor) - rightMargin + (128 * scaleFactor)
        return CGPoint(x: x, y: y)
    }
    
    private func positionForRoomItem(_ overlay: ItemOverlay, geometry: GeometryProxy) -> CGPoint {
        let index = viewModel.roomItemOverlays.firstIndex(where: { $0.id == overlay.id }) ?? 0
        let padding = 15 * scaleFactor
        let itemSize = 48 * scaleFactor
        let itemSpacing = 10 * scaleFactor
        
        let x = padding + CGFloat(index) * (itemSize + itemSpacing) + (itemSize / 2)
        let y: CGFloat = (5 * scaleFactor) + (itemSize / 2)
        return CGPoint(x: x, y: y)
    }
    
    private func positionForInventoryItem(_ overlay: ItemOverlay, geometry: GeometryProxy) -> CGPoint {
        let index = viewModel.inventoryOverlays.firstIndex(where: { $0.id == overlay.id }) ?? 0
        let padding = 15 * scaleFactor
        let itemSize = 48 * scaleFactor
        let itemSpacing = 10 * scaleFactor
        
        let x = padding + CGFloat(index) * (itemSize + itemSpacing) + (itemSize / 2)
        let y = geometry.size.height - itemSize - padding + (itemSize / 2)
        return CGPoint(x: x, y: y)
    }
}
// MARK: - Preview

#Preview {
    let vm = TransitionOverlayViewModel()
    vm.addCharacterOverlay(nameKey: "character_guard", imageName: "character_guard")
    vm.addRoomItemOverlay(id: UUID(), nameKey: "item_wrench", imageName: "item_wrench")
    vm.addInventoryOverlay(id: UUID(), nameKey: "item_beamer", imageName: "item_beamer")
    return TransitionOverlayView(currentBackground: .constant("sas.gif"), viewModel: .constant(vm), scaleFactor: 1.0)
        .frame(width: 900, height: 680)
        .background(Color.black)
}
