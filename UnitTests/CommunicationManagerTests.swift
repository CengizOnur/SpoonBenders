//
//  CommunicationManagerTests.swift
//  UnitTests
//
//  Created by con akd on 6.07.2022.
//

@testable import Spoon_Benders
import XCTest

class CommunicationManagerTests: XCTestCase {
    
    // System(s) Under Tests
    var sutOne: GameCommunication!
    var sutTwo: GameCommunication!
    var sutThree: GameCommunication!
    
    // Mocks
    var mockMqttOne: MockMqtt!
    var mockMqttTwo: MockMqtt!
    var mockMqttThree: MockMqtt!
    
    var mockMqttBroker: MockMqttBroker!
    
    // Players
    var playerOne: Player!
    var playerTwo: Player!
    var playerThree: Player!

    
    override func setUp() {
        super.setUp()
        mockMqttBroker = MockMqttBroker()
    }

    override func tearDown() {
        // Players
        playerOne = nil
        playerTwo = nil
        playerThree = nil
        
        // Mocks
        mockMqttOne = nil
        mockMqttTwo = nil
        mockMqttThree = nil
        
        mockMqttBroker = nil
        
        // Suts
        sutOne = nil
        sutTwo = nil
        sutThree = nil
        
        super.tearDown()
    }


    // MARK: - Given
    
    func givenPlayerToBeHost() {
        playerOne = Player(playerNickname: "Onr", playerImageName: "😎", playerCode: "1", isHost: true)
    }
    
    
    func givenPlayerToBePlayerTwo() {
        playerTwo = Player(playerNickname: "Cng", playerImageName: "🤪", playerCode: "2", isHost: false)
    }
    
    
    func givenPlayerToBePlayerThree() {
        playerThree = Player(playerNickname: "Akd", playerImageName: "😍", playerCode: "3", isHost: false)
    }

    
    // MARK: - When
    
    func whenPlayerOneJoinedGame() {
        mockMqttOne = MockMqtt(broker: mockMqttBroker)
        sutOne = GameCommunication(player: playerOne, gameCode: "456", gameMode: .ffa, mqtt: mockMqttOne)
    }
    
    
    func whenPlayerTwoJoinedGame() {
        mockMqttTwo = MockMqtt(broker: mockMqttBroker)
        sutTwo = GameCommunication(player: playerTwo, gameCode: "456", gameMode: .ffa, mqtt: mockMqttTwo)
    }
    
    
    func whenPlayerThreeJoinedGame() {
        mockMqttThree = MockMqtt(broker: mockMqttBroker)
        sutThree = GameCommunication(player: playerThree, gameCode: "456", gameMode: .ffa, mqtt: mockMqttThree)
    }
    
    
    // MARK: - Tests
    
    func test_gameCommunication_conformsToCommunicationManagerService() {
        // given
        givenPlayerToBeHost()
        // when
        whenPlayerOneJoinedGame()
        // then
        XCTAssertTrue((sutOne as AnyObject) is CommunicationManagerService)
    }


    func test_communicationManager_mqttSet() {
        // given
        givenPlayerToBeHost()
        // when
        whenPlayerOneJoinedGame()
        // then
        XCTAssertTrue((sutOne.mqtt?.delegate) === sutOne)
        let subscribed = mockMqttBroker.subscribers[0]
        XCTAssertTrue(subscribed === sutOne)
    }
    
    
    func test_communicationManager_thereIsOnePlayerAndSetCorrectly() {
        // given
        givenPlayerToBeHost()
        // when
        whenPlayerOneJoinedGame()
        // then
        XCTAssertEqual(sutOne.playersCodes.count, 1)
        
        let hostsPlayerCode = sutOne.playersCodes[0]
        XCTAssertEqual(sutOne.players[hostsPlayerCode],
                       [playerOne.playerImageName, playerOne.playerNickname])
    }
    
    
    func test_communicationManager_mqttPublishMessage() {
        // given
        givenPlayerToBeHost()
        // when
        whenPlayerOneJoinedGame()
        let expectedTopic = "testTopic"
        let expectedMessage = "testMessage"
        sutOne.mqtt?.publish(expectedTopic, withString: expectedMessage, qos: .qos1, retained: false)
        // then
        XCTAssertEqual(sutOne.message?.topic, expectedTopic)
        XCTAssertEqual(sutOne.message?.string, expectedMessage)
    }
    
    
    func test_communicationManager_publishMessage() {
        // given
        givenPlayerToBeHost()
        // when
        whenPlayerOneJoinedGame()
        let expectedMessage = "testMessage"
        sutOne.publishMessage(message: expectedMessage)
        // then
        XCTAssertEqual(sutOne.message?.string, expectedMessage)
    }
    
    
    func test_communicationManager_whenPlayerTwoJoined_thereAreTwoPlayerAndSetCorrectly() {
        // given
        givenPlayerToBeHost()
        givenPlayerToBePlayerTwo()
        // when
        whenPlayerOneJoinedGame()
        whenPlayerTwoJoinedGame()
        // then
        XCTAssertEqual(sutOne.playersCodes.count, 2)
        XCTAssertEqual(sutTwo.playersCodes.count, 2)
        
        let subscribedHost = mockMqttBroker.subscribers[0]
        let subscribedPlayerTwo = mockMqttBroker.subscribers[1]
        XCTAssertTrue(subscribedHost === sutOne)
        XCTAssertTrue(subscribedPlayerTwo === sutTwo)
        XCTAssertEqual(mockMqttBroker.subscribers.count, 2)
    }
    
    
    func test_communicationManager_whenPlayerTwoDisconnected_thereIsJustPlayerOneAndSetCorrectly() {
        // given
        givenPlayerToBeHost()
        givenPlayerToBePlayerTwo()
        // when
        whenPlayerOneJoinedGame()
        whenPlayerTwoJoinedGame()
        XCTAssertEqual(mockMqttBroker.subscribers.count, 2)
        sutTwo.publishMessage(message: "Disconnected:\(playerTwo.playerCode)")
        sutTwo.disconnect()
        // then
        XCTAssertEqual(sutOne.playersCodes.count, 1)
        XCTAssertEqual(mockMqttBroker.subscribers.count, 1)
        
        let subscribedHost = mockMqttBroker.subscribers[0]
        XCTAssertTrue(subscribedHost === sutOne)
        XCTAssertEqual(mockMqttBroker.subscribers.count, 1)
    }
    
    
    func test_communicationManager_whenPlayerThreeConnectedAfterPlayerTwoDisconnected_thereAreTwoPlayersAndSetCorrectly() {
        // given
        givenPlayerToBeHost()
        givenPlayerToBePlayerTwo()
        givenPlayerToBePlayerThree()
        // when
        whenPlayerOneJoinedGame()
        whenPlayerTwoJoinedGame()
        XCTAssertEqual(mockMqttBroker.subscribers.count, 2)
        sutTwo.publishMessage(message: "Disconnected:\(playerTwo.playerCode)")
        sutTwo.disconnect()
        whenPlayerThreeJoinedGame()
        // then
        XCTAssertEqual(sutOne.playersCodes.count, 2)
        XCTAssertEqual(mockMqttBroker.subscribers.count, 2)
        
        let subscribedHost = mockMqttBroker.subscribers[0]
        let subscribedPlayerTwo = mockMqttBroker.subscribers[1]
        XCTAssertTrue(subscribedHost === sutOne)
        XCTAssertTrue(subscribedPlayerTwo === sutThree)
        XCTAssertEqual(mockMqttBroker.subscribers.count, 2)
    }
    
    
    func test_communicationManager_whenHostDisconnected_nextPlayerIsHost() {
        // given
        givenPlayerToBeHost()
        givenPlayerToBePlayerTwo()
        whenPlayerOneJoinedGame()
        whenPlayerTwoJoinedGame()
        // when
        XCTAssertFalse(sutTwo.player.isHost)
        sutOne.publishMessage(message: "Disconnected:\(playerOne.playerCode)")
        sutOne.disconnect()
        whenPlayerOneJoinedGame()
        // then
        XCTAssertTrue(sutTwo.player.isHost)
    }
    
    
    
    
//    func test_communicationManager_whenPlayerThreeJoined_thereAreThreePlayerAndSetCorrectly() {
//        // given
//        givenPlayerToBeHost()
//        givenPlayerToBePlayerTwo()
//        givenPlayerToBePlayerThree()
//        // when
//        whenHostCreateRoom()
//        whenPlayerTwoJoinedGame()
//        whenPlayerThreeJoinedGame()
//        // then
//        XCTAssertEqual(sutOne.playersCodes.count, 3)
//        XCTAssertEqual(sutTwo.playersCodes.count, 3)
//
//        let subscribedHost = mockMqttBroker.subscribers[0]
//        let subscribedPlayerTwo = mockMqttBroker.subscribers[1]
//        let subscribedPlayerThree = mockMqttBroker.subscribers[2]
//        XCTAssertTrue(subscribedHost === sutOne)
//        XCTAssertTrue(subscribedPlayerTwo === sutTwo)
//        XCTAssertTrue(subscribedPlayerThree === sutThree)
//
//    }
    
}
