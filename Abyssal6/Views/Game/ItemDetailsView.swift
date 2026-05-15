//
//  ItemDetailsView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

/// A modal view that shows detailed information about an item and offers relevant actions.
struct ItemDetailsView: View {
    let item: Item
    let onAction: (ItemAction) -> Void

    @Environment(\.dismiss) private var dismiss

    enum ItemAction {
        case use
        case eat
        case charge
        case fire
        case drop      // optional, if you want quick drop from details
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Icon and title
                HStack {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)

                    VStack(alignment: .leading) {
                        Text(Lang.string(item.name))
                            .font(.title2.bold())
                            .foregroundColor(.abyssalAccent)
                        Text(item.type.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.abyssalDim)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Divider()

                // Details grid
                Grid(horizontalSpacing: 20, verticalSpacing: 12) {
                    GridRow {
                        Text(Lang.string("item_weight"))
                            .fontWeight(.medium)
                        Text(String(format: "%.1f kg", Double(item.weight) / 1000.0))
                            .foregroundColor(.abyssalText)
                    }
                    GridRow {
                        Text(Lang.string("item_pickable"))
                            .fontWeight(.medium)
                        Text(item.canBePickedUp ? Lang.string("yes") : Lang.string("no"))
                            .foregroundColor(item.canBePickedUp ? .abyssalSuccess : .abyssalDanger)
                    }
                    GridRow {
                        Text(Lang.string("item_type"))
                            .fontWeight(.medium)
                        Text(item.type.rawValue)
                            .foregroundColor(.abyssalDim)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Action buttons (only show applicable ones)
                VStack(spacing: 12) {
                    if item.isUsable {
                        ActionButton(title: Lang.string("use"), color: .abyssalAccent) {
                            onAction(.use)
                            dismiss()
                        }
                    }
                    if item.type == .magicCookie {
                        ActionButton(title: Lang.string("eat"), color: .abyssalSuccess) {
                            onAction(.eat)
                            dismiss()
                        }
                    }
                    if let beamer = item as? Beamer {
                        if !beamer.isCharged {
                            ActionButton(title: Lang.string("charge"), color: .orange) {
                                onAction(.charge)
                                dismiss()
                            }
                        } else {
                            ActionButton(title: Lang.string("fire"), color: .purple) {
                                onAction(.fire)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .background(Color.abyssalBg.ignoresSafeArea())
            .navigationTitle(Lang.string("item_details_title"))
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

// MARK: - Helper Button

private struct ActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let sampleItem = ItemType.beamer.createItem()
    return ItemDetailsView(item: sampleItem) { action in
        print("Action: \(action)")
    }
}
