//
//  InventoryItemRow.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

// MARK: - Inventory Item Row

struct InventoryItemRow: View {
    let item: Item
    let isOwned: Bool
    let onAction: (Item, InventoryAction) -> Void

    @State private var showingActionSheet = false

    var body: some View {
        HStack {
            // Icon
            Image(item.imageName)
                .resizable()
                .frame(width: 32, height: 32)
                .cornerRadius(6)

            // Name and weight
            VStack(alignment: .leading, spacing: 4) {
                Text(Lang.string(item.name))
                    .font(.headline)
                    .foregroundColor(.abyssalText)
                Text(String(format: "%.1f kg", Double(item.weight) / 1000.0))
                    .font(.caption)
                    .foregroundColor(.abyssalDim)
            }

            Spacer()

            // Action button (context menu on iOS)
            Menu {
                // Inspect is always available
                Button(Lang.string("inspect")) {
                    onAction(item, .inspect)
                }

                if isOwned {
                    Divider()
                    // Drop
                    Button(Lang.string("drop")) {
                        onAction(item, .drop)
                    }
                    // Use (if usable)
                    if item.isUsable {
                        Button(Lang.string("use")) {
                            onAction(item, .use)
                        }
                    }
                    // Eat (if magic cookie)
                    if item.type == .magicCookie {
                        Button(Lang.string("eat")) {
                            onAction(item, .eat)
                        }
                    }
                    // Beamer specific
                    if let beamer = item as? Beamer {
                        Divider()
                        if !beamer.isCharged {
                            Button(Lang.string("charge")) {
                                onAction(item, .charge)
                            }
                        } else {
                            Button(Lang.string("fire")) {
                                onAction(item, .fire)
                            }
                        }
                    }
                } else {
                    // Room item – can take if pickable
                    if item.canBePickedUp {
                        Divider()
                        Button(Lang.string("take")) {
                            onAction(item, .take)
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundColor(.abyssalAccent)
            }
        }
        .padding(.vertical, 4)
    }
}
