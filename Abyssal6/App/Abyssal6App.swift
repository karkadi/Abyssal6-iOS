//
//  Abyssal6App.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import SwiftUI

@main
struct Abyssal6App: App {
    @State private var engine = GameEngine()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(engine)
        }
    }
}
