//
//  TalkDialogView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 17/05/2026.
//
import SwiftUI

struct TalkDialogData: Identifiable {
    let id = UUID()
    let characters: [StaticCharacter]
}

/// A modal that lists all characters in the current room.
/// Selecting a character sends the "talk <characterNameKey>" command.
struct TalkDialogView: View {
    let characters: [StaticCharacter]
    let onTalk: (String) -> Void   // passes the character's nameKey

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            if characters.isEmpty {
                VStack {
                    Spacer()
                    Text(Lang.string("no_characters_here"))
                        .foregroundColor(.abyssalDim)
                    Spacer()
                }
                .navigationTitle(Lang.string("talk_title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Lang.string("cancel")) {
                            dismiss()
                        }
                    }
                }
            } else {
                List(characters) { character in
                    Button {
                        onTalk(character.nameKey)
                        dismiss()
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
                                    .lineLimit(2)
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
                .navigationTitle(Lang.string("talk_title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(Lang.string("cancel")) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

#Preview {
    let dummyRoom = Room(key: "room_sas", imageName: "sas.gif")
    let sampleCharacters = [
        StaticCharacter(nameKey: "character_guard", descriptionKey: "character_guard_desc", currentRoom: dummyRoom),
        StaticCharacter(nameKey: "character_doctor", descriptionKey: "character_doctor_desc", currentRoom: dummyRoom)
    ]
    return TalkDialogView(characters: sampleCharacters) { nameKey in
        print("Talk to \(nameKey)")
    }
}
