//
//  BenderTests.swift
//  UnitTests
//
//  Created by con akd on 20.07.2022.
//

@testable import Spoon_Benders
import XCTest

class BenderTests: XCTestCase {
    
    var indivudualBenderFactory: IndividualBenderFactory!
    var teammateBenderFactory: TeammateBenderFactory!
    
    override func setUp() {
        super.setUp()
        indivudualBenderFactory = IndividualBenderFactory()
        teammateBenderFactory = TeammateBenderFactory()
    }
    
    override func tearDown() {
        indivudualBenderFactory = nil
        teammateBenderFactory = nil
        super.tearDown()
    }
    
    
    // MARK: - Individuals
    
    func test_individualBenderFactory_createsIndividualCats() {
        // when
        let individualKitten = indivudualBenderFactory.createKitten()
        let individualCat = indivudualBenderFactory.createCat()
        // then
        XCTAssertTrue(individualKitten is IndividualKitten)
        XCTAssertTrue(individualKitten is IndividualCat)
        XCTAssertTrue((individualKitten as AnyObject) is IndividualBender)
        XCTAssertTrue((individualKitten as AnyObject) is Bender)
        
        XCTAssertTrue(individualCat is IndividualCat)
        XCTAssertFalse(individualCat is IndividualKitten)
        XCTAssertTrue((individualCat as AnyObject) is IndividualBender)
        XCTAssertTrue((individualCat as AnyObject) is Bender)
        
    }
    
    
    func test_individualBenderFactory_createsIndividualRobots() {
        // when
        let individualRobot = indivudualBenderFactory.createRobot()
        // then
        XCTAssertTrue(individualRobot is IndividualRobot)
        XCTAssertTrue((individualRobot as AnyObject) is IndividualBender)
        XCTAssertTrue((individualRobot as AnyObject) is Bender)
    }
    
    
    func test_individualBenderFactory_createsIndividualBoys() {
        // when
        let individualBoyWithRedHat = indivudualBenderFactory.createBoyWithRedHat()
        let individualBoy = indivudualBenderFactory.createBoy()
        // then
        XCTAssertTrue(individualBoyWithRedHat is IndividualBoyWithRedHat)
        XCTAssertTrue(individualBoyWithRedHat is IndividualBoy)
        XCTAssertTrue((individualBoyWithRedHat as AnyObject) is IndividualBender)
        XCTAssertTrue((individualBoyWithRedHat as AnyObject) is Bender)
        
        XCTAssertTrue(individualBoy is IndividualBoy)
        XCTAssertFalse(individualBoy is IndividualBoyWithRedHat)
        XCTAssertTrue((individualBoy as AnyObject) is IndividualBender)
        XCTAssertTrue((individualBoy as AnyObject) is Bender)
    }
    
    
    func test_individualBenderFactory_createsIndividualNinjagirl() {
        // when
        let individualNinjagirl = indivudualBenderFactory.createNinjagirl()
        // then
        XCTAssertTrue(individualNinjagirl is IndividualNinjagirl)
        XCTAssertTrue((individualNinjagirl as AnyObject) is IndividualBender)
        XCTAssertTrue((individualNinjagirl as AnyObject) is Bender)
    }
    
    
    // MARK: - Teammates
    
    func test_teammateBenderFactory_createsTeammateCats() {
        // when
        let teammateKitten = teammateBenderFactory.createKitten()
        let teammateCat = teammateBenderFactory.createCat()
        // then
        XCTAssertTrue(teammateKitten is TeammateKitten)
        XCTAssertTrue(teammateKitten is TeammateCat)
        XCTAssertTrue((teammateKitten as AnyObject) is TeammateBender)
        XCTAssertTrue((teammateKitten as AnyObject) is Bender)
        
        XCTAssertTrue(teammateCat is TeammateCat)
        XCTAssertFalse(teammateCat is TeammateKitten)
        XCTAssertTrue((teammateCat as AnyObject) is TeammateBender)
        XCTAssertTrue((teammateCat as AnyObject) is Bender)
        
    }
    
    
    func test_teammateBenderFactory_createsTeammateRobots() {
        // when
        let teammateRobot = teammateBenderFactory.createRobot()
        // then
        XCTAssertTrue(teammateRobot is TeammateRobot)
        XCTAssertTrue((teammateRobot as AnyObject) is TeammateBender)
        XCTAssertTrue((teammateRobot as AnyObject) is Bender)
    }
    
    
    func test_teammateBenderFactory_createsTeammateBoys() {
        // when
        let teammateBoyWithRedHat = teammateBenderFactory.createBoyWithRedHat()
        let teammateBoy = teammateBenderFactory.createBoy()
        // then
        XCTAssertTrue(teammateBoyWithRedHat is TeammateBoyWithRedHat)
        XCTAssertTrue(teammateBoyWithRedHat is TeammateBoy)
        XCTAssertTrue((teammateBoyWithRedHat as AnyObject) is TeammateBender)
        XCTAssertTrue((teammateBoyWithRedHat as AnyObject) is Bender)
        
        XCTAssertTrue(teammateBoy is TeammateBoy)
        XCTAssertFalse(teammateBoy is TeammateBoyWithRedHat)
        XCTAssertTrue((teammateBoy as AnyObject) is TeammateBender)
        XCTAssertTrue((teammateBoy as AnyObject) is Bender)
    }
    
    
    func test_teammateBenderFactory_createsTeammateNinjagirl() {
        // when
        let teammateNinjagirl = teammateBenderFactory.createNinjagirl()
        // then
        XCTAssertTrue(teammateNinjagirl is TeammateNinjagirl)
        XCTAssertTrue((teammateNinjagirl as AnyObject) is TeammateBender)
        XCTAssertTrue((teammateNinjagirl as AnyObject) is Bender)
    }
}
