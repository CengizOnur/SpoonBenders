//
//  Utilities.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 5.04.2023.
//

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


enum Orientation {
    case portrait
    case landscape
}


enum SoundType: String {
    case turn
    case select
    case notSelected
    case attack
}
