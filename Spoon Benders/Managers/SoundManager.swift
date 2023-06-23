//
//  SoundManager.swift
//  Spoon Benders
//
//  Created by con akd on 31.03.2023.
//

import Foundation
import AVFoundation

class SoundManager {
    
    var player: AVAudioPlayer!
    var isSoundOpen = true
    
    
    func playSound() {
        guard isSoundOpen else { return }
        
        let noUrl = URL(string: "noUrl")!
        let url = Bundle.main.url(forResource: "B", withExtension: "wav")
        
        player = try? AVAudioPlayer(contentsOf: url ?? noUrl)
        player.play()
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("SoundManager is deallocated")
    }
}
