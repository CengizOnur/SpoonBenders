//
//  Boys.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 20.07.2022.
//

import Foundation

// MARK: - Individual Boys

class IndividualBoy: IndividualBender {
    
    var name: String
    var imageName: String
    var fullHealth: Int
    var health: Int {
        didSet {
            if health <= 0 {
                health = 0
                state = .gaveUp
            }
        }
    }
    var attack: Int
    var state: BenderState
    weak var opponent: Bender? {
        didSet {
            attack += getBonusAgainstOpponent(attacker: self, defender: opponent)
        }
    }
    
    init(name: String = "Boy", imageName: String = "boy", fullHealth: Int = 100, health: Int = 100, attack: Int = 25, state: BenderState = .idle) {
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
        self.state = state
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("IndividualBoy is deallocated")
    }
}


final class IndividualBoyWithRedHat: IndividualBoy {
    
    override init(name: String = "BoyWithRedHat", imageName: String = "boyWithRedHat", fullHealth: Int = 100, health: Int = 100, attack: Int = 20, state: BenderState = .idle) {
        super.init()
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
        self.state = state
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("IndividualBoyWithRedHat is deallocated")
    }
}


// MARK: - Teammate Boys

class TeammateBoy: TeammateBender {
    
    var name: String
    var imageName: String
    var fullHealth: Int
    var health: Int {
        didSet {
            if health <= 0 {
                health = 0
                state = .gaveUp
            }
        }
    }
    var attack: Int
    var state: BenderState
    
    weak var opponent: Bender? {
        didSet {
            attack += getBonusAgainstOpponent(attacker: self, defender: opponent)
        }
    }
    
    weak var teammate: Bender? {
        didSet {
            attack += getCooperationAttackBonus(bender: self, teammateBender: teammate)
        }
    }
    
    init(name: String = "Boy", imageName: String = "boy", fullHealth: Int = 100, health: Int = 100, attack: Int = 25, state: BenderState = .idle) {
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
        self.state = state
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("TeammateBoy is deallocated")
    }
}


final class TeammateBoyWithRedHat: TeammateBoy {
    
    override init(name: String = "BoyWithRedHat",imageName: String = "boyWithRedHat", fullHealth: Int = 100, health: Int = 100,  attack: Int = 25, state: BenderState = .idle) {
        super.init()
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
        self.state = state
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("TeammateBoyWithRedHat is deallocated")
    }
}
