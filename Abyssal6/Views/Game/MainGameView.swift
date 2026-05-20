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
    @State private var commandInput: String = ""
    @FocusState private var isInputFocused: Bool
    // Baseline reference height standard matching secondary puzzle views
    private let refHeight: CGFloat = 680

    var body: some View {
        GeometryReader { geometry in
            // 1. Establish a global vertical scaling index factor
            let scaleY = geometry.size.height / refHeight

            HStack(spacing: 12) {
                // Left side: Game visual + terminal
                VStack(spacing: 12) {
                    // Transition overlay (background + overlays)
                    TransitionOverlayView(
                        currentBackground: $viewModel.currentRoomImageName,
                        viewModel: $viewModel.transitionOverlayVM,
                        scaleFactor: scaleY // Pass height scaling down to internal child subviews
                    )
                    .frame(height: geometry.size.height * 0.65)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Terminal
                    TerminalView(viewModel: viewModel.terminalVM, scaleFactor: scaleY)
                        .frame(height: geometry.size.height * 0.3)
                }
                .frame(width: geometry.size.width * 0.68)

                // Right side: Control panel
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
                            AbyssalButton(title: button.title, color: .abyssalAccent) {
                                viewModel.sendCommand(button.command)
                            }
                            .frame(height: 50 * scaleY)
                            .font(.system(size: 14 * scaleY))
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

                        AbyssalButton(title: "GO", color: .abyssalAccent) {
                            isInputFocused = false
                            sendCommand()
                        }
                        .frame(width: 60 * scaleY, height: 44 * scaleY)
                    }
                    .padding(.horizontal)

                    Divider().background(Color.abyssalDim)

                    // Action buttons (grid 3x3)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12 * scaleY) {
                        ForEach(actionButtons, id: \.title) { button in
                            AbyssalButton(title: button.title, color: .abyssalAccent) {
                                if button.action == .inventory {
                                    viewModel.showingInventory = true
                                } else if button.action == .talk {
                                    viewModel.showTalkDialog()
                                } else if button.action == .give {
                                    viewModel.showGiveDialog()
                                } else {
                                    viewModel.sendCommand(button.command)
                                }
                            }
                            .frame(height: 50 * scaleY)
                            .font(.system(size: 13 * scaleY))
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .frame(width: geometry.size.width * 0.28)
                .padding(.vertical)
            }
            .padding(12 * scaleY)
            // Added horizontal safety padding so text/buttons don't clip behind hardware notches
            .padding(.horizontal, geometry.safeAreaInsets.leading > 0 ? 0 : 8)
        }
        // FIX: Moved .ignoresSafeArea() out to the parent view container level
        .background(Color.abyssalBg)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            viewModel.refreshUI()
        }
        .sheet(isPresented: $viewModel.showingInventory) {
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
                viewModel.showingInventory = false
            }
        }
        .sheet(isPresented: $viewModel.showingCharacterInteraction) {
            if let character = viewModel.selectedCharacter {
                CharacterInteractionSheet(
                    character: character,
                    mode: viewModel.characterInteractionMode,
                    inventory: viewModel.inventoryItems
                ) { selectedItem in
                    if viewModel.characterInteractionMode == .talk {
                        viewModel.talkToCharacter(character)
                    } else if let item = selectedItem {
                        viewModel.giveItemToCharacter(character, item: item)
                    }
                    viewModel.showingCharacterInteraction = false
                }
            }
        }
        .sheet(item: $viewModel.displayedItemForDetails) { item in
            ItemDetailsView(item: item) { action in
                switch action {
                case .use:
                    viewModel.interpretCommand("use \(item.name)")
                case .eat:
                    viewModel.interpretCommand("eat \(item.name)")
                case .charge:
                    viewModel.interpretCommand("charge")
                case .fire:
                    viewModel.interpretCommand("fire")
                    viewModel.refreshUI()
                case .drop:
                    viewModel.interpretCommand("drop \(item.name)")
                }
                viewModel.dismissItemDetails()
            }
        }
        .sheet(item: $viewModel.giveDialogData) { data in
            GiveDialogView(characters: data.characters, inventory: data.inventory) { characterNameKey, item in
                viewModel.giveItemToCharacter(characterNameKey: characterNameKey, item: item)
                viewModel.dismissGiveDialog()
            }
        }
        .sheet(item: $viewModel.talkDialogCharacters) { data in
            TalkDialogView(characters: data.characters) { nameKey in
                viewModel.talkToCharacter(nameKey: nameKey)
            }
        }
        .fullScreenCover(item: $viewModel.easterEggTorch) { torch in
            EasterEggView(torch: torch) {
                viewModel.easterEggTorch = nil
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showItemDetails)) { notification in
            if let item = notification.object as? Item {
                viewModel.showItemDetails(item)
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("timeLeftDidChange"))) { _ in
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
        ActionButton(title: "LOOK", command: "look", action: .command),
        ActionButton(title: "INV", command: "", action: .inventory),
        ActionButton(title: "BACK", command: "back", action: .command),
        ActionButton(title: "TALK", command: "", action: .talk),
        ActionButton(title: "GIVE", command: "", action: .give),
        ActionButton(title: "HELP", command: "help", action: .command),
        ActionButton(title: "SAVE", command: "save game", action: .command),
        ActionButton(title: "LOAD", command: "load game", action: .command),
        ActionButton(title: "QUIT", command: "quit", action: .command)
    ]
}

// MARK: - Preview

#Preview {
    MainGameView()
}
