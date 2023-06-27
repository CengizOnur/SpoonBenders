//
//  Robot.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 19.07.2022.
//

import Foundation

// MARK: - Individual Robot

final class IndividualRobot: IndividualBender {
    
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
    
    init(name: String = "Robot", imageName: String = "robot", fullHealth: Int = 100, health: Int = 100, attack: Int = 40, state: BenderState = .idle) {
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
        self.state = state
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("IndividualRobot is deallocated")
    }
}


// MARK: - Teammate Robot

final class TeammateRobot: TeammateBender {
    
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
    
    init(name: String = "Robot", imageName: String = "robot", fullHealth: Int = 100, health: Int = 100, attack: Int = 40, state: BenderState = .idle) {
        self.name = name
        self.imageName = imageName
        self.fullHealth = fullHealth
        self.health = health
        self.attack = attack
        self.state = state
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("TeammateRobot is deallocated")
    }
}
