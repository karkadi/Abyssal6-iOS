//
//  InventoryPickerView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

// MARK: - Inventory Picker (for give dialog)

struct InventoryPickerView: View {
    let items: [Item]
    let onSelect: (Item) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(items) { item in
                Button(action: {
                    onSelect(item)
                    dismiss()
                }) {
                    HStack {
                        Image(item.imageName)
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text(item.name)
                        Spacer()
                        Text(String(format: "%.1f kg", Double(item.weight) / 1000))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(Lang.string("select_item"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
