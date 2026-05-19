//
//  IntroViewModel.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 19/05/2026.
//
import SwiftUI
import DIContainer

@Observable
final class IntroViewModel {
    @ObservationIgnored
    @Injected private var engine: GameEngineProtocol
    
    func stopBackgroundMusic(){
        engine.stopBackgroundMusic()
    }
    
    func startMission(){
        engine.startMission()
    }
    
    func playBackgroundMusic(_ file: String){
        engine.playBackgroundMusic(file)
    }
    
}
