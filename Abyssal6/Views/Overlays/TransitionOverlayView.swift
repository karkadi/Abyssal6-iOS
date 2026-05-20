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
    @State private var showMenu = false
    @State private var menuCharacter: StaticCharacter?
    @State private var menuItem: (item: Item, type: ItemOverlay.ItemOverlayType)?

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
            .overlay(
                Group {
                    if let character = viewModel.calloutCharacter {
                        CharacterCalloutView(character: character) {
                            viewModel.dismissCallout()
                        }
                        .transition(.opacity)
                    }
                }
            )
            .overlay(
                Group {
                    if showMenu {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showMenu = false
                            }
                            .overlay(
                                ContextMenuView(
                                    character: menuCharacter,
                                    item: menuItem,
                                    onAction: { action in
                                        handleMenuAction(action)
                                        showMenu = false
                                    }
                                ), alignment: menuAlignment)
                    }
                }
            )
        }
        .onAppear {
            viewModel.setBackground(imageName: currentBackground)
            refreshAllOverlays()
            viewModel.showCalloutsForCurrentRoom()
        }
        .onChange(of: currentBackground) { _, newImage in
            viewModel.setBackground(imageName: newImage)
        }
        .onReceive(NotificationCenter.default.publisher(for: .roomDidChange)) { notification in
            if let room = notification.object as? Room {
                viewModel.setBackground(imageName: room.imageName)
            }
            showMenu = false
            refreshAllOverlays()
            viewModel.showCalloutsForCurrentRoom()
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

    private var menuAlignment: Alignment {
        if let menuItem = menuItem {
            return menuItem.type == .inventory ? .bottomLeading : .topLeading
        }

        return Alignment(horizontal: .trailing, vertical: .center)
    }

    private func handleMenuAction(_ action: ContextMenuView.MenuAction) {
        switch action {
        case .talk:
            if let character = menuCharacter {
                viewModel.interpretCommand("talk \(character.nameKey)")
            }
        case .give:
            viewModel.interpretCommand("give")
        case .inspect:
            if let (item, _) = menuItem {
                viewModel.showItemDetails(item)
            }
        case .take:
            if let (item, _) = menuItem {
                viewModel.interpretCommand("take \(item.name)")
            }
        case .drop:
            if let (item, _) = menuItem {
                viewModel.interpretCommand("drop \(item.name)")
            }
        case .use:
            if let (item, _) = menuItem {
                viewModel.interpretCommand("use \(item.name)")
            }
        case .eat:
            if let (item, _) = menuItem {
                viewModel.interpretCommand("eat \(item.name)")
            }
        case .charge:
            viewModel.interpretCommand("charge")
        case .fire:
            viewModel.interpretCommand("fire")
        case .cancel:
            break
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
            .onTapGesture { _ in
                if let character = findCharacter(byNameKey: overlay.nameKey) {
                    menuCharacter = character
                    menuItem = nil
                    showMenu = true
                }
            }
    }

    @ViewBuilder
    private func itemImageView(for overlay: ItemOverlay) -> some View {
        Image(overlay.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 48 * scaleFactor, height: 48 * scaleFactor)
            .shadow(radius: 2 * scaleFactor)
            .onTapGesture { _ in
                if let item = findItem(byId: overlay.id, type: overlay.type) {
                    menuItem = (item, overlay.type)
                    menuCharacter = nil
                    showMenu = true
                }
            }
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

        let posX = startX + CGFloat(index) * overlayWidth + (64 * scaleFactor)
        let posY = geometry.size.height - (256 * scaleFactor) - rightMargin + (128 * scaleFactor)
        return CGPoint(x: posX, y: posY)
    }

    private func positionForRoomItem(_ overlay: ItemOverlay, geometry: GeometryProxy) -> CGPoint {
        let index = viewModel.roomItemOverlays.firstIndex(where: { $0.id == overlay.id }) ?? 0
        let padding = 15 * scaleFactor
        let itemSize = 48 * scaleFactor
        let itemSpacing = 10 * scaleFactor

        let posX = padding + CGFloat(index) * (itemSize + itemSpacing) + (itemSize / 2)
        let posY: CGFloat = (5 * scaleFactor) + (itemSize / 2)
        return CGPoint(x: posX, y: posY)
    }

    private func positionForInventoryItem(_ overlay: ItemOverlay, geometry: GeometryProxy) -> CGPoint {
        let index = viewModel.inventoryOverlays.firstIndex(where: { $0.id == overlay.id }) ?? 0
        let padding = 15 * scaleFactor
        let itemSize = 48 * scaleFactor
        let itemSpacing = 10 * scaleFactor

        let posX = padding + CGFloat(index) * (itemSize + itemSpacing) + (itemSize / 2)
        let posY = geometry.size.height - itemSize - padding + (itemSize / 2)
        return CGPoint(x: posX, y: posY)
    }
}
// MARK: - Preview

#Preview {
    let viewModel = TransitionOverlayViewModel()
    viewModel.addCharacterOverlay(nameKey: "character_guard", imageName: "character_guard")
    viewModel.addRoomItemOverlay(id: UUID(), nameKey: "item_wrench", imageName: "item_wrench")
    viewModel.addInventoryOverlay(id: UUID(), nameKey: "item_beamer", imageName: "item_beamer")
    return TransitionOverlayView(currentBackground: .constant("sas.gif"), viewModel: .constant(viewModel), scaleFactor: 1.0)
        .frame(width: 900, height: 680)
        .background(Color.black)
}
