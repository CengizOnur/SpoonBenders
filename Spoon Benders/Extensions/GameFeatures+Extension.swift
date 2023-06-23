//
//  GameFeatures+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 5.04.2023.
//

import Foundation

enum GameMode {
    case oneVsOne
    case twoVsTwo
    case ffa
}


/// 1vs1 and FFA are individual, 2vs2 is teamplay.
enum PlayMode {
    case individual
    case teamplay
}


/// After first bender(attacker) attacks(firstAttack), it will be defender and second bender(defender) will be attacker(reactionAttack).
enum DuelType {
    case firstAttack
    case reactionAttack
}


enum BenderState {
    case idle
    case selected
    case attacking
    case defending
    case gaveUp
}


extension GameMode {
    
    var convertToString: String {
        switch self {
        case .oneVsOne:
            return "1v1"
        case .twoVsTwo:
            return "2v2"
        case .ffa:
            return "FFA"
        }
    }
    
    var convertToInt: Int {
        switch self {
        case .oneVsOne:
            return 2
        case .twoVsTwo:
            return 4
        default:
            return 1
        }
    }
}
