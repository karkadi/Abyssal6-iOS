//
//  TerminalView.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

// MARK: - Terminal View
struct TerminalView: View {
    @State private var viewModel: TerminalViewModel
    let scaleFactor: CGFloat // Scaling down font constraints relative to device height
    
    init(viewModel: TerminalViewModel = TerminalViewModel(), scaleFactor: CGFloat = 1.0) {
        _viewModel = State(initialValue: viewModel)
        self.scaleFactor = scaleFactor
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(viewModel.text)
                    .font(.custom("Menlo", size: 14 * scaleFactor))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16 * scaleFactor)
                    .id("bottom")
            }
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
            )
            .onChange(of: viewModel.text) { _, _ in
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .gameLog)) { notification in
                if let message = notification.object as? String {
                    viewModel.append(message)
                } else if let message = notification.userInfo?["message"] as? String {
                    viewModel.append(message)
                }
            }
        }
    }
    
    // MARK: - Public API (can be exposed via the viewModel, but for convenience)
    func append(_ text: String) {
        viewModel.append(text)
    }
    
    func typewrite(_ text: String, delay: TimeInterval = 0.03) {
        viewModel.typewrite(text, delay: delay)
    }
    
    func clear() {
        viewModel.clear()
    }
}

// MARK: - Preview

#Preview {
    let vm = TerminalViewModel()
    vm.append("Welcome to Abyssal-6")
    vm.typewrite("This is a typewriter effect...", delay: 0.05)
    return TerminalView(viewModel: vm)
        .frame(width: 600, height: 300)
        .padding()
        .background(Color.gray.opacity(0.2))
}
