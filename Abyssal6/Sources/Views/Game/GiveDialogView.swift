//
//  GiveDialogView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

struct GiveDialogData: Identifiable {
    let id = UUID()
    let characters: [StaticCharacter]
    let inventory: [Item]
}

/// A two‑step modal for giving an item to a character:
/// 1. Choose a character from the current room.
/// 2. Choose an item from the player's inventory.
struct GiveDialogView: View {
    let characters: [StaticCharacter]
    let inventory: [Item]
    let onComplete: (String?, Item?) -> Void   // (characterNameKey, item) – item may be nil if cancelled

    @Environment(\.dismiss) private var dismiss

    @State private var selectedCharacter: StaticCharacter?
    @State private var selectedItem: Item?
    @State private var step: Step = .selectCharacter

    enum Step {
        case selectCharacter
        case selectItem
    }

    var body: some View {
        NavigationView {
            VStack {
                if step == .selectCharacter {
                    characterSelectionView
                } else {
                    itemSelectionView
                }
            }
            .navigationTitle(step == .selectCharacter ? Lang.string("give_title") : Lang.string("give_choose_item"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.string("cancel")) {
                        onComplete(nil, nil)
                        dismiss()
                    }
                }
                if step == .selectItem {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(Lang.string("back")) {
                            withAnimation { step = .selectCharacter }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Character Selection

    @ViewBuilder
    private var characterSelectionView: some View {
        if characters.isEmpty {
            VStack {
                Spacer()
                Text(Lang.string("no_characters_here"))
                    .foregroundColor(.abyssalDim)
                Spacer()
            }
        } else {
            List(characters) { character in
                Button {
                    selectedCharacter = character
                    withAnimation { step = .selectItem }
                } label: {
                    HStack {
                        Image(character.nameKey)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text(character.localizedName)
                                .font(.headline)
                                .foregroundColor(.abyssalText)
                            Text(character.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.abyssalDim)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.abyssalAccent)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.abyssalBg)
        }
    }

    // MARK: - Item Selection

    @ViewBuilder
    private var itemSelectionView: some View {
        if inventory.isEmpty {
            VStack {
                Spacer()
                Text(Lang.string("inventory_empty"))
                    .foregroundColor(.abyssalDim)
                Spacer()
            }
        } else {
            List(inventory) { item in
                Button {
                    selectedItem = item
                    // Complete: give the selected item to the selected character
                    onComplete(selectedCharacter?.nameKey, selectedItem)
                    dismiss()
                } label: {
                    HStack {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                        VStack(alignment: .leading) {
                            Text(Lang.string(item.name))
                                .font(.headline)
                                .foregroundColor(.abyssalText)
                            Text(String(format: "%.1f kg", Double(item.weight) / 1000.0))
                                .font(.caption)
                                .foregroundColor(.abyssalDim)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.abyssalBg)
        }
    }
}

#Preview {
    // Create a dummy room for the preview characters
    let dummyRoom = Room(key: "room_sas", imageName: "sas.gif")

    let sampleCharacters = [
        StaticCharacter(nameKey: "character_guard", descriptionKey: "character_guard_desc", currentRoom: dummyRoom),
        StaticCharacter(nameKey: "character_doctor", descriptionKey: "character_doctor_desc", currentRoom: dummyRoom)
    ]

    let sampleItems: [Item] = [
        ItemType.wrench.createItem(),
        ItemType.beamer.createItem(),
        ItemType.magicCookie.createItem()
    ]

    return GiveDialogView(
        characters: sampleCharacters,
        inventory: sampleItems
    ) { characterNameKey, item in
        print("Gave \(item?.name ?? "nothing") to \(characterNameKey ?? "nobody")")
    }
}
