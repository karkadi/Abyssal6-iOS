//
//  MainGameView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 16/05/2026.
//
import SwiftUI

// MARK: - Main Game View

struct MainGameView: View {
    @State private var viewModel = GameViewModel()
    @State private var commandInput = ""
    @FocusState private var isInputFocused: Bool
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    private let refHeight: CGFloat = 680
    private var scaleX: CGFloat { isPad ? 0.28 : 0.33 }

    var body: some View {
        GeometryReader { geometry in
            let scaleY = geometry.size.height / refHeight

            HStack(spacing: 12) {
                VStack(spacing: 12) {
                    TransitionOverlayView(
                        currentBackground: $viewModel.currentRoomImageName,
                        viewModel: $viewModel.transitionOverlayVM,
                        scaleFactor: scaleY
                    )
                    .frame(height: geometry.size.height * 0.65)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    TerminalView(viewModel: viewModel.terminalVM, scaleFactor: scaleY)
                        .frame(height: geometry.size.height * 0.3)
                }
                .frame(width: geometry.size.width * 0.68)

                // Right panel (unchanged layout)
                VStack(spacing: max(8, 16 * scaleY)) {
                    // Timer and room label
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.abyssalAccent)
                            .font(.system(size: 18 * scaleY))
                        Text(viewModel.timeString)
                            .font(.system(size: 20 * scaleY, weight: .regular, design: .monospaced))
                            .foregroundColor(.abyssalAccent)
                        Spacer()
                        Text(viewModel.currentRoomName)
                            .font(.system(size: 16 * scaleY, weight: .semibold))
                            .foregroundColor(.abyssalText)
                    }
                    .padding(.horizontal)

                    // Direction pad (4x2 grid)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12 * scaleY) {
                        ForEach(directionButtons, id: \.title) { button in
                            AbyssalButton(title: button.title, color: .abyssalAccent, scaleY: scaleY) {
                                viewModel.sendCommand(button.command)
                            }
                            .frame(height: 50 * scaleY)
                        }
                    }
                    .padding(.horizontal)

                    // Command input field
                    HStack {
                        TextField("Enter command", text: $commandInput)
                            .focused($isInputFocused)
                            .textFieldStyle(.plain)
                            .padding(12 * scaleY)
                            .background(Color.abyssalPanel)
                            .cornerRadius(8)
                            .foregroundColor(.abyssalText)
                            .font(.custom("Menlo", size: 14 * scaleY))
                            .onSubmit(sendCommand)

                        AbyssalButton(title: "GO", color: .abyssalAccent, scaleY: scaleY) {
                            isInputFocused = false
                            sendCommand()
                        }
                        .frame(width: 60 * scaleY, height: 44 * scaleY)
                    }
                    .padding(.horizontal)

                    Divider().background(Color.abyssalDim)
                        .padding(.trailing, 36 * scaleY)

                    // Action buttons (grid 3x3)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12 * scaleY) {
                        ForEach(actionButtons, id: \.title) { button in
                            AbyssalButton(title: button.title, color: .abyssalAccent, scaleY: scaleY) {
                                if button.action == .inventory {
                                    viewModel.coordinator.showingInventory = true
                                } else if button.action == .talk {
                                    viewModel.showTalkDialog()
                                } else if button.action == .give {
                                    viewModel.showGiveDialog()
                                } else {
                                    viewModel.sendCommand(button.command)
                                }
                            }
                            .frame(height: 50 * scaleY)
                            .font(.system(size: 8 * scaleY))
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .frame(width: geometry.size.width * scaleX)
                .padding(.vertical)

            }
            .padding(12 * scaleY)
        }
        .background(Color.abyssalBg)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear { viewModel.refreshUI() }
        // MARK: - Sheets using coordinator via viewModel’s injected coordinator
        .sheet(isPresented: Binding(
            get: { viewModel.coordinator.showingInventory },
            set: { if !$0 { viewModel.coordinator.dismissInventory() } }
        )) {
            InventoryView(items: viewModel.inventoryItems, roomItems: viewModel.roomItems) { item, action in
                switch action {
                case .take: viewModel.takeItem(item)
                case .drop: viewModel.dropItem(item)
                case .use: viewModel.useItem(item)
                case .eat: viewModel.eatItem(item)
                case .inspect: viewModel.showItemDetails(item)
                case .charge: viewModel.sendCommand("charge")
                case .fire: viewModel.sendCommand("fire")
                }
                viewModel.coordinator.dismissInventory()
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.coordinator.showingCharacterInteraction },
            set: { if !$0 { viewModel.coordinator.dismissCharacterInteraction() } }
        )) {
            if let character = viewModel.coordinator.selectedCharacter {
                CharacterInteractionSheet(
                    character: character,
                    mode: viewModel.coordinator.characterInteractionMode,
                    inventory: viewModel.inventoryItems
                ) { selectedItem in
                    if viewModel.coordinator.characterInteractionMode == .talk {
                        viewModel.talkToCharacter(character)
                    } else if let item = selectedItem {
                        viewModel.giveItemToCharacter(character, item: item)
                    }
                    viewModel.coordinator.dismissCharacterInteraction()
                }
            }
        }
        .sheet(item: Binding(
            get: { viewModel.coordinator.displayedItemForDetails },
            set: { if $0 == nil { viewModel.coordinator.dismissItemDetails() } }
        )) { item in
            ItemDetailsView(item: item) { action in
                switch action {
                case .use: viewModel.interpretCommand("use \(item.name)")
                case .eat: viewModel.interpretCommand("eat \(item.name)")
                case .charge: viewModel.interpretCommand("charge")
                case .fire: viewModel.interpretCommand("fire"); viewModel.refreshUI()
                case .drop: viewModel.interpretCommand("drop \(item.name)")
                }
                viewModel.coordinator.dismissItemDetails()
            }
        }
        .sheet(item: Binding(
            get: { viewModel.coordinator.giveDialogData },
            set: { if $0 == nil { viewModel.coordinator.dismissGiveDialog() } }
        )) { data in
            GiveDialogView(characters: data.characters, inventory: data.inventory) { characterNameKey, item in
                viewModel.giveItemToCharacter(characterNameKey: characterNameKey, item: item)
                viewModel.coordinator.dismissGiveDialog()
            }
        }
        .sheet(item: Binding(
            get: { viewModel.coordinator.talkDialogCharacters },
            set: { if $0 == nil { viewModel.coordinator.dismissTalkDialog() } }
        )) { data in
            TalkDialogView(characters: data.characters) { nameKey in
                viewModel.talkToCharacter(nameKey: nameKey)
            }
        }
        .fullScreenCover(item: Binding(
            get: { viewModel.coordinator.easterEggTorch },
            set: { if $0 == nil { viewModel.coordinator.dismissEasterEgg() } }
        )) { torch in
            EasterEggView(torch: torch) {
                viewModel.coordinator.dismissEasterEgg()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showGiveDialog)) { _ in
            viewModel.showGiveDialog()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTalkDialog)) { _ in
            viewModel.showTalkDialog()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showEasterEgg)) { notification in
            if let torch = notification.object as? Torch {
                viewModel.showEasterEgg(for: torch)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .timeLeftDidChange)) { _ in
            viewModel.updateTime()
        }
    }

    private func sendCommand() {
        guard !commandInput.isEmpty else { return }
        viewModel.sendCommand(commandInput)
        commandInput = ""
    }

    // MARK: - Button Definitions

    private struct ActionButton: Identifiable {
        let id = UUID()
        let title: String
        let command: String
        let action: ButtonAction
    }

    private enum ButtonAction {
        case command
        case inventory
        case talk
        case give
    }

    private let directionButtons: [ActionButton] = [
        ActionButton(title: "⬆ UP", command: "go up", action: .command),
        ActionButton(title: "↑ N", command: "go north", action: .command),
        ActionButton(title: "⬇ DOWN", command: "go down", action: .command),
        ActionButton(title: "← W", command: "go west", action: .command),
        ActionButton(title: "↓ S", command: "go south", action: .command),
        ActionButton(title: "→ E", command: "go east", action: .command)
    ]

    private let actionButtons: [ActionButton] = [
        ActionButton(title: Lang.string("gui_look"), command: "look", action: .command),
        ActionButton(title: Lang.string("gui_inv"), command: "", action: .inventory),
        ActionButton(title: Lang.string("gui_back"), command: "back", action: .command),
        ActionButton(title: Lang.string("gui_talk"), command: "", action: .talk),
        ActionButton(title: Lang.string("gui_give"), command: "", action: .give),
        ActionButton(title: Lang.string("gui_help"), command: "help", action: .command),
        ActionButton(title: Lang.string("gui_save"), command: "save game", action: .command),
        ActionButton(title: Lang.string("gui_load"), command: "load game", action: .command),
        ActionButton(title: Lang.string("gui_quit"), command: "quit", action: .command)
    ]
}

// MARK: - Preview

#Preview {
    MainGameView()
}
