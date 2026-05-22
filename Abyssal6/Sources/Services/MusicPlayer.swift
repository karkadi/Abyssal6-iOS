//
//  MusicPlayer.swift
//  Abyssal6
//
//  Created by Arkadiy KAZAZYAN on 15/05/2026.
//
import AVFoundation

final class MusicPlayer {
    private var backgroundPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    func playBackgroundMusic(_ file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else {
            print("Background music file not found: \(file)")
            return
        }
        backgroundPlayer = try? AVAudioPlayer(contentsOf: url)
        backgroundPlayer?.numberOfLoops = -1
        backgroundPlayer?.volume = 0.3
        backgroundPlayer?.play()
    }

    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
        backgroundPlayer = nil
    }

    /// Plays a short sound effect once.
    /// - Parameter soundFile: Name of the sound file (without extension, assumed .wav)
    func playSFX(_ soundFile: String) {
        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "wav") else {
            print("SFX file not found: \(soundFile)")
            return
        }
        // Create a new player for each SFX to allow overlapping sounds
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = 0.5
            sfxPlayer?.prepareToPlay()
            sfxPlayer?.play()
            // Keep a reference to prevent deallocation; store in a separate property if needed.
            // For simplicity, we don't store it; it will play and be released.
            // If you need to stop it early, store it in a dictionary.
        } catch {
            print("Failed to play SFX \(soundFile): \(error.localizedDescription)")
        }
    }
}
