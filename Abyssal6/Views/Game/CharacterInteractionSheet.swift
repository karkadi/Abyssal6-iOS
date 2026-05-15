//
//  CharacterInteractionSheet.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

// MARK: - Character Interaction Sheet

struct CharacterInteractionSheet: View {
    let character: StaticCharacter
    let mode: CharacterInteractionMode
    let inventory: [Item]
    let onComplete: (Item?) -> Void
    
    @State private var selectedItem: Item?
    @State private var showingItemPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(mode == .talk ? Lang.string("talk_title") : Lang.string("give_title"))
                .font(.title2)
                .foregroundColor(.abyssalAccent)
            
            Text(character.localizedName)
                .font(.headline)
                .foregroundColor(.abyssalText)
            
            if mode == .talk {
                Text(character.fullDescription)
                    .font(.body)
                    .padding()
                    .background(Color.abyssalPanel)
                    .cornerRadius(8)
            } else {
                if inventory.isEmpty {
                    Text(Lang.string("inventory_empty"))
                        .foregroundColor(.abyssalDim)
                } else {
                    Button(Lang.string("select_item")) {
                        showingItemPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if let item = selectedItem {
                        Text("Selected: \(item.name)")
                            .foregroundColor(.abyssalSuccess)
                    }
                }
            }
            
            HStack(spacing: 20) {
                AbyssalButton(title: Lang.string("cancel"), color: .abyssalDanger) {
                    onComplete(nil)
                }
                if mode == .give && selectedItem != nil {
                    AbyssalButton(title: Lang.string("give_button"), color: .abyssalSuccess) {
                        onComplete(selectedItem)
                    }
                } else if mode == .talk {
                    AbyssalButton(title: Lang.string("talk_button"), color: .abyssalAccent) {
                        onComplete(nil)
                    }
                }
            }
        }
        .padding()
        .background(Color.abyssalBg)
        .sheet(isPresented: $showingItemPicker) {
            InventoryPickerView(items: inventory) { item in
                selectedItem = item
                showingItemPicker = false
            }
        }
    }
}

