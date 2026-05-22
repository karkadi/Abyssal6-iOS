//
//  ContextMenuView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 20/05/2026.
//
import SwiftUI

struct ContextMenuView: View {
    let character: StaticCharacter?
    let item: (item: Item, type: ItemOverlay.ItemOverlayType)?
    let onAction: (MenuAction) -> Void

    enum MenuAction {
        case talk
        case give
        case inspect
        case take
        case drop
        case use
        case eat
        case charge
        case fire
        case cancel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let character = character {
                // Character menu
                Button(action: { onAction(.talk) }, label: {
                    Label(Lang.string("talk_button"), systemImage: "bubble.left")
                        .frame(maxWidth: .infinity, alignment: .leading)
                })
                if !character.exchangeItems.isEmpty {
                    Button(action: { onAction(.give)  }, label: {
                        Label(Lang.string("give_button"), systemImage: "gift")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                }
            } else if let (item, type) = item {
                // Item menu
                Button(action: { onAction(.inspect)  }, label: {
                    Label(Lang.string("inspect"), systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                })

                if type == .roomItem && item.canBePickedUp {
                    Button(action: { onAction(.take)  }, label: {
                        Label(Lang.string("take"), systemImage: "hand.raised")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                } else if type == .inventory {
                    Button(action: { onAction(.drop)  }, label: {
                        Label(Lang.string("drop"), systemImage: "trash")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    if item.isUsable {
                        Button(action: { onAction(.use)  }, label: {
                            Label(Lang.string("use"), systemImage: "hammer")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        })
                    }
                    if item.type == .magicCookie {
                        Button(action: { onAction(.eat)  }, label: {
                            Label(Lang.string("eat"), systemImage: "fork.knife")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        })
                    }
                    if let beamer = item as? Beamer {
                        if !beamer.isCharged {
                            Button(action: { onAction(.charge)  }, label: {
                                Label(Lang.string("charge"), systemImage: "bolt")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                        } else {
                            Button(action: { onAction(.fire)  }, label: {
                                Label(Lang.string("fire"), systemImage: "flame")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                        }
                    }
                }
            }

            Divider()
            Button(action: { onAction(.cancel) },
                   label: {
                Label(Lang.string("cancel"), systemImage: "xmark")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.red)
            })
        }
        .padding()
        .frame(width: 220)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.abyssalPanel)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.abyssalAccent.opacity(0.5), lineWidth: 1)
        )
        .padding(8)
    }
}
