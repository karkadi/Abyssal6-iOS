//
//  InventoryView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

// MARK: - Inventory Action

enum InventoryAction {
    case take
    case drop
    case use
    case eat
    case inspect
    case charge
    case fire
}

// MARK: - Inventory View

struct InventoryView: View {
    let items: [Item]          // player's inventory
    let roomItems: [Item]      // items in current room
    let onAction: (Item, InventoryAction) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // Player's items section
                Section(header: Text(Lang.string("inventory"))
                    .font(.headline)
                    .foregroundColor(.abyssalAccent)) {
                        ForEach(items) { item in
                            InventoryItemRow(item: item, isOwned: true, onAction: onAction)
                        }
                    }

                // Room items section
                Section(header: Text(Lang.string("inventory"))
                    .font(.headline)
                    .foregroundColor(.abyssalDim)) {
                        ForEach(roomItems) { item in
                            InventoryItemRow(item: item, isOwned: false, onAction: onAction)
                        }
                    }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.abyssalBg)
            .navigationTitle(Lang.string("inventory_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.string("close")) {
                        dismiss()
                    }
                    .foregroundColor(.abyssalAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    let dummyItems = [
        ItemType.torch.createItem(),
        ItemType.wrench.createItem()
    ]
    let dummyRoomItems = [
        ItemType.blueCard.createItem(),
        ItemType.genetic.createItem()
    ]
    return InventoryView(items: dummyItems, roomItems: dummyRoomItems) { item, action in
        print("Action \(action) on \(item.name)")
    }
}
