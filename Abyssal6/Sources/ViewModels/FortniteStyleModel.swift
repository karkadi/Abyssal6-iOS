//
//  FortniteStyleModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 23/05/2026.
//

import SwiftUI
import DIContainer

@Observable
@MainActor
final class FortniteStyleModel {
    let models: [ModelItem] = [
        ModelItem(name: "character_doctor", displayName: "character_doctor"),
        ModelItem(name: "character_guard", displayName: "character_guard"),
        ModelItem(name: "character_scientist", displayName: "character_scientist"),
        ModelItem(name: "character_engineer", displayName: "character_engineer"),
        ModelItem(name: "character_nurse", displayName: "character_nurse"),
        ModelItem(name: "character_stalker", displayName: "character_stalker"),
        ModelItem(name: "character_geneticist", displayName: "character_geneticist"),
        ModelItem(name: "character_researcher", displayName: "character_researcher"),
        ModelItem(name: "character_wandering_tech", displayName: "character_wandering_tech")
    ]

    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol

    func showIntro() {
        engine.gameState = .intro
    }

    func playBackgroundMusic(_ file: String) {
        engine.playBackgroundMusic(file)
    }

}
