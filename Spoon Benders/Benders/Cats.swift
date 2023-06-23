//
//  Cats.swift
//  Spoon Benders
//
//  Created by con akd on 19.07.2022.
//

import Foundation

// MARK: - Individual Cats

class IndividualCat: IndividualBender {
    
    var name: String
    var imageName: String
    var fullHealth: Int
    var health: Int {
        didSet {
            if health == 0 {
                state = .gaveUp
            }
        }
    }
    var attack: Int
    var state: BenderState = .idle
    
    weak var opponent: Bender? {
        didSet {
            attack += getBonusAgainstOpponent(attacker: self, defender: opponent)
        }
    }
    
    init(name: String = "Cat", imageName: String = "cat", fullHealth: Int = 100, health: Int = 100, attack: Int = 25) {
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("IndividualCat is deallocated")
    }
}


class IndividualKitten: IndividualCat {
    
    override init(name: String = "Kitten", imageName: String = "kitten", fullHealth: Int = 100, health: Int = 100, attack: Int = 1) {
        super.init()
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("IndividualKitten is deallocated")
    }
}


// MARK: - Teammate Cats

class TeammateCat: TeammateBender {
    
    var name: String
    var imageName: String
    var fullHealth: Int
    var health: Int {
        didSet {
            if health == 0 {
                state = .gaveUp
            }
        }
    }
    var attack: Int
    var state: BenderState = .idle
    
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
    
    
    init(name: String = "Cat", imageName: String = "cat", fullHealth: Int = 100, health: Int = 100, attack: Int = 25, bonusAttackPoint: Int = 0) {
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("TeammateCat is deallocated")
    }
}


class TeammateKitten: TeammateCat {
    
    override init(name: String = "Kitten",imageName: String = "kitten", fullHealth: Int = 100, health: Int = 100,  attack: Int = 10, bonusAttackPoint: Int = 0) {
        super.init()
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("TeammateKitten is deallocated")
    }
}
