//
//  RootViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 19/05/2026.
//
import SwiftUI
import DIContainer

@Observable
final class RootViewModel {
    var gameState: GameState = .intro
    
    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol
    
    func restartGame(){
        engine.restartGame()
    }
}
