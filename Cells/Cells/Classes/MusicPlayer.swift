//
//  MusicPlayer.swift
//  Cells
//
//  Created by Gustavo De Mello Crivelli on 24/01/18.
//  Copyright © 2018 Gustavo De Mello Crivelli. All rights reserved.
//

import AVFoundation

// Music player class. Controls BGM.
class MusicPlayer {

    private var backgroundMusicPlayer: AVAudioPlayer!

    init() {
        loadBackgroundMusic(filename: "DiscoHigh.mp3")
    }

    func loadBackgroundMusic(filename: String) {

        let resourceUrl = Bundle.main.url(forResource:
            filename, withExtension: nil)
        guard let url = resourceUrl else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            try backgroundMusicPlayer =
                AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
        } catch {
            print("Could not create audio player!")
            return
        }
        backgroundMusicPlayer.volume = 0.7
    }

    func playBackgroundMusic() {
        backgroundMusicPlayer.play()
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer.stop()
    }

    func setVolume(volume: Float) {
        let chopped = min(1.0, max(0.0, volume))
        backgroundMusicPlayer.volume = 0.7 * chopped
    }
}
