//
//  SoundManager.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 31.03.2023.
//

import Foundation
import AVFoundation

final class SoundManager {
    
    var player: AVAudioPlayer!
    var isSoundOpen = true
    
    
    func play(_ sound: SoundType) {
        guard isSoundOpen else { return }
        
        let soundName = sound.rawValue
        let noUrl = URL(string: "noUrl")!
        let url = Bundle.main.url(forResource: soundName, withExtension: "wav")
        
        player = try? AVAudioPlayer(contentsOf: url ?? noUrl)
        
        player.prepareToPlay()
        player.play()
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("SoundManager is deallocated")
    }
}
