//
//  Bender.swift
//  Spoon Benders
//
//  Created by con akd on 19.07.2022.
//

import Foundation

// MARK: - Bender Protocols

protocol Bender: AnyObject {
    
    var name: String { get }
    var imageName: String { get set }
    var fullHealth: Int { get set }
    var health: Int { get set }
    var attack: Int { get set }
    var state: BenderState { get set }
    var opponent: Bender? { get set }
}


protocol IndividualBender: Bender {
    
    var name: String { get }
    var imageName: String { get set }
    var fullHealth: Int { get set }
    var health: Int { get set }
    var attack: Int { get set }
    var state: BenderState { get set }
    var opponent: Bender? { get set }
}


protocol TeammateBender: Bender {
    
    var name: String { get }
    var imageName: String { get set }
    var fullHealth: Int { get set }
    var health: Int { get set }
    var attack: Int { get set }
    var state: BenderState { get set }
    var opponent: Bender? { get set }
    var teammate: Bender? { get set }
}


// MARK: - Abstract Factory

protocol BenderFactory {
    
    func createCat() -> Bender
    func createKitten() -> Bender
    func createRobot() -> Bender
    func createBoy() -> Bender
    func createBoyWithRedHat() -> Bender
    func createNinjagirl() -> Bender
}


// MARK: - Concrete Factories

class IndividualBenderFactory: BenderFactory {
    
    func createCat() -> Bender { return IndividualCat() }
    func createKitten() -> Bender { return IndividualKitten() }
    func createRobot() -> Bender { return IndividualRobot() }
    func createBoy() -> Bender { return IndividualBoy() }
    func createBoyWithRedHat() -> Bender { return IndividualBoyWithRedHat() }
    func createNinjagirl() -> Bender { return IndividualNinjagirl() }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("IndividualBenderFactory is deallocated")
    }
}


class TeammateBenderFactory: BenderFactory {
    
    func createCat() -> Bender { return TeammateCat() }
    func createKitten() -> Bender { return TeammateKitten() }
    func createRobot() -> Bender { return TeammateRobot() }
    func createBoy() -> Bender { return TeammateBoy() }
    func createBoyWithRedHat() -> Bender { return TeammateBoyWithRedHat() }
    func createNinjagirl() -> Bender { return TeammateNinjagirl() }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("TeammateBenderFactory is deallocated")
    }
}


// MARK: - Utility Functions

extension Bender {
    
    func getCooperationAttackBonus(bender: Bender, teammateBender: Bender?) -> Int {
        switch (bender, teammateBender) {
        case (_, nil):
            let negativeEffectOfBeingAbandoned = -10
            return negativeEffectOfBeingAbandoned
        case (is TeammateCat, is TeammateBoyWithRedHat), (is TeammateBoyWithRedHat, is TeammateCat):
            return 10
        case (is TeammateRobot, is TeammateBoy), (is TeammateBoy, is TeammateRobot):
            return 15
        case (is TeammateKitten, is TeammateNinjagirl):
            return 20
        case (is TeammateNinjagirl, is TeammateKitten):
            return 5
        default:
            return 0
        }
    }
    
    
    func getBonusAgainstOpponent(attacker: Bender, defender: Bender?) -> Int {
        switch (attacker.name, defender?.name) {
        case ("Cat", "BoyWithRedHat"):
            return 15
        case ("Cat", "Boy"):
            return 10
        case ("Robot", "Cat"):
            return 5
        case ("BoyWithRedHat", "Boy"):
            return 15
        case ("Boy", "Ninjagirl"):
            return 5
        case ("Ninjagirl", "Robot"):
            return 5
        default:
            return 0
        }
    }
}


// MARK: - Bender Assignment

extension SpoonBenders {
    
    enum WhichBender {
        static let cat = 1
        static let kitten = 2
        static let robot = 3
        static let boy = 4
        static let boyWithRedHat = 5
        static let ninjagirl = 6
    }
    
    
    func assignBender(by randomNumber: Int, mode: PlayMode) -> Bender {
        let factory: BenderFactory = mode == .individual ? IndividualBenderFactory() : TeammateBenderFactory()
        switch randomNumber {
        case WhichBender.cat:
            return factory.createCat()
        case WhichBender.kitten:
            return factory.createKitten()
        case WhichBender.robot:
            return factory.createRobot()
        case WhichBender.boy:
            return factory.createBoy()
        case WhichBender.boyWithRedHat:
            return factory.createBoyWithRedHat()
        case WhichBender.ninjagirl:
            return factory.createNinjagirl()
        default: break
            
        }
        return factory.createCat()
    }
}
