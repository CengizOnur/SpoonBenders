//
//  GameCommunication.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 2.03.2022.
//

import Foundation
import UIKit
import CocoaMQTT

protocol GameCommunicationDelegate: AnyObject {
    
    func timeIsUpApproved(message: String)
    func moveMade(by player: String, onTrio: String, at index: Int)
    func didPlayersUpdated()
    func didPlayerDrop(playerCode: String)
    func startGame()
}


extension GameCommunicationDelegate {
    
    func moveMade(by player: String, onTrio: String, at index: Int) { }
    func didPlayersUpdated() { }
    func startGame() { }
}


final class GameCommunication {
    
    private lazy var clientID = "CocoaMQTT-\(player.playerCode)-" + String(ProcessInfo().processIdentifier)
    private let defaultHost = "test.mosquitto.org"
    
    weak var delegate: GameCommunicationDelegate?
    
    var message: CocoaMQTTMessage? = nil
    private var nextPlayerNumber = 1
    
    var playersCodes: [String] = []
    var players: [String : [String]] = [:]
    var playersAndBenders: [String : [Int]] = [:]
    
    var player: Player
    private var gameCode: String?
    var gameMode: GameMode
    var gameStarted = false
    
    /// To track players moves for getting synchronized game experience
    var moveState = 0
    
    /// To track timer synchronization
    var timeIsUp = 0
    
    private lazy var numberOfPlayers = gameMode == .oneVsOne ? 2 : 4
    
    var mqtt: MqttProtocol?
    
    
    init(player: Player, gameCode: String, gameMode: GameMode, mqtt: MqttProtocol? = nil) {
        self.player = player
        self.gameCode = gameCode
        self.gameMode = gameMode

        self.mqtt = {
            /// Testing purposes: To create mock object in unit tests.
            if let mqtt = mqtt {
                return mqtt
            }
            /// Production Code
            return CocoaMQTT(clientID: clientID, host: defaultHost, port: 1883)
        }()
        
        if player.isHost {
            playersCodes.append(player.playerCode)
            players[player.playerCode] = [player.playerImageName, player.playerNickname]
            nextPlayerNumber += 1
        }
        mqttSetting()
        _ = self.mqtt?.connect()
    }
    
    
    // MARK: - MqttSettings
    
    private func mqttSetting() {
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
    }
    
    
    // MARK: - New Player
    
    func declareSubscription() {
        if !player.isHost {
            let playerAttributes = [player.playerCode, player.playerImageName, player.playerNickname]
            let newPlayerMessage = "newPlayer:\(playerAttributes.description)"
            publishMessage(message: newPlayerMessage)
        }
    }
    
    
    func newPlayerJoined(newPlayerAttributes: String) {
        guard !gameStarted, players.count < numberOfPlayers else { return }
        let newPlayer = convertStringPlayersToArray(from: newPlayerAttributes)
        let newPlayersCode = newPlayer[0]
        guard !playersCodes.contains(newPlayersCode) else { return }
        playersCodes.append(newPlayersCode)
        players[newPlayer[0]] = [newPlayer[1], newPlayer[2]]
        nextPlayerNumber += 1
        delegate?.didPlayersUpdated()
        publishMessage(message: "\(players.description)-\(playersCodes.description)")
        checkWeAreFull()
    }
    
    
    // MARK: - Update
    
    func updatePlayers(stringPlayers: String) {
        let playersStrings = String(stringPlayers.split(separator: "-")[0])
        let playersCodesStrings = String(stringPlayers.split(separator: "-")[1])
        playersCodes = convertStringPlayersToArray(from: playersCodesStrings)
        players = convertToDictionary(stringPlayers: playersStrings)
        for key in players.keys {
            if !playersCodes.contains(key) {
                playersCodes.append(key)
            }
        }
        delegate?.didPlayersUpdated()
        checkWeAreFull()
    }
    
    
    func updateBenders(playerCode: String, stringBenders: String) {
        let bendersNumbers = convertStringBendersToArray(from: stringBenders)
        playersAndBenders[playerCode] = bendersNumbers
        checkWeAreReady()
    }
    
    
    // MARK: - Check To Start
    
    func checkWeAreFull() {
        if numberOfPlayers == players.count {
            let benders = Int.randomNumbers(from: 1, to: 6)
            let bendersMessage = "Benders:\(benders.description)"
            publishMessage(message: bendersMessage)
        }
    }
    
    
    func checkWeAreReady() {
        if numberOfPlayers == playersAndBenders.count {
            gameStarted = true
            delegate?.startGame()
        }
    }
    
    
    // MARK: - Publish Message
    
    func publishMessage(message: String) {
        mqtt!.publish("gameSB/playersSB/client/Host\(gameCode!)/" + player.playerCode, withString: message, qos: .qos1, retained: false)
    }
    
    
    // MARK: - Disconnection
    
    func disconnect() {
        mqtt!.disconnect()
    }
    
    
    func playerDisconnected(playerCode: String) {
        playersCodes = playersCodes.filter { $0 != playerCode }
        players = players.filter { $0.key != playerCode }
        
        nextPlayerNumber -= 1
        guard playersCodes.count > 0 else { return }
        
        if player.playerCode == playersCodes[0] {
            player.isHost = true
        }
        delegate?.didPlayerDrop(playerCode: playerCode)
        guard player.isHost else { return }
        delegate?.didPlayersUpdated()
        publishMessage(message: "\(players.description)-\(playersCodes.description)")
    }
    
    
    // MARK: - Handle Functions
    
    func handleTimeIsUp(message: String) {
        let components = message.description.components(separatedBy: "-")
        let moveStateString = components[1].components(separatedBy: ":")[1]
        let moveState = Int(moveStateString)!
        guard self.moveState == moveState else { return }
        timeIsUp += 1
        if timeIsUp == playersCodes.count {
            timeIsUp = 0
            self.moveState += 1
            let approveTimeIsUpMessage = "TimeIsUpApproved-MoveState:\(self.moveState)"
            publishMessage(message: approveTimeIsUpMessage)
        }
    }
    
    
    func handleTimeIsUpApproved(message: String) {
        let components = message.description.components(separatedBy: "-")
        let moveStateString = components[1].components(separatedBy: ":")[1]
        let moveState = Int(moveStateString)!
        self.moveState = moveState
        delegate?.timeIsUpApproved(message: message)
    }
    
    
    func handleMove(move: String) {
        let message = move.description.components(separatedBy: "=>")
        let moveState = message[0].components(separatedBy: ":")[1]
        
        /// For consistency, all players should be on same state
        guard self.moveState == Int(moveState) else { return }
        self.moveState += 1
        let approvedMove = message[1] + "-MoveState:\(self.moveState)"
        publishMessage(message: approvedMove)
    }
    
    
    func handleApprovedMove(message: String) {
        /// let's say:
        /// - MoveBy:165-MoveOn:183-WhichBender:2-MoveState:6
        ///
        let components = message.components(separatedBy: "-")
        /// 165
        let playerCode = components[0].components(separatedBy: ":")[1]
        /// 141
        let onPlayer = components[1].components(separatedBy: ":")[1]
        /// 2
        let whichBender = components[2].components(separatedBy: ":")[1]
        let moveState = components[3].components(separatedBy: ":")[1]
        /// 6
        self.moveState = Int(moveState)!
        delegate?.moveMade(by: playerCode, onTrio: onPlayer, at: Int(whichBender)!)
    }
    
    
    // MARK: - Message Distribution
    
    func messageDistributor(message: CocoaMQTTMessage) {
        self.message = message
        
        switch message {
            
        case let msg where msg.string!.split(separator: ":")[0] == "Benders":
            let playerCode = message.topic.split(separator: "/").last.map { String($0) }
            updateBenders(playerCode: playerCode!, stringBenders: String(message.string!.split(separator: ":")[1]))
        
        case let msg where msg.string!.split(separator: ":")[0] == "TimeIsUp":
            guard player.isHost else { return }
            handleTimeIsUp(message: msg.string!)
        
        case let msg where msg.string!.split(separator: ":")[0] == "MoveState":
            guard player.isHost else { return }
            handleMove(move: message.string!)
        
        case let msg where msg.string!.split(separator: ":")[0] == "MoveBy":
            handleApprovedMove(message: msg.string!)
        
        case let msg where msg.string!.split(separator: "-")[0] == "TimeIsUpApproved":
            handleTimeIsUpApproved(message: msg.string!)
            
        case let msg where msg.topic == "gameSB/playersSB/client/Host\(gameCode!)/" + player.playerCode:
            return
        
        case let msg where msg.string!.split(separator: ":")[0] == "newPlayer":
            guard player.isHost else { return }
            newPlayerJoined(newPlayerAttributes: String(message.string!.split(separator: ":")[1]))
        
        case let msg where String((msg.string?.split(separator: ":")[0])!) == "Disconnected":
            playerDisconnected(playerCode: String((message.string?.split(separator: ":")[1])!))
        
        case let msg where msg.string!.first == "[":
            updatePlayers(stringPlayers: message.string!)
            
        default:
            return
        }
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("GameCommunication is deallocated")
    }
}


// MARK: - CocoaMQTTDelegate

extension GameCommunication: CocoaMQTTDelegate {
    
    // MARK: - Connected
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        if ack == .accept {
            mqtt.subscribe("gameSB/playersSB/client/Host\(gameCode!)/+", qos: CocoaMQTTQoS.qos1)
        }
        declareSubscription()
    }
    
    
    // MARK: - Published Message
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string.description), id: \(id)")
        let firstWordisDisconnected = String((message.string?.split(separator: ":")[0])!)
        if firstWordisDisconnected == "Disconnected" {
            disconnect()
        }
    }
    
    
    // MARK: - Received Message
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        messageDistributor(message: message)
    }
    
    
}

// MARK: - Other Functions

extension GameCommunication {
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        TRACE("subscribed: \(success), failed: \(failed)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.description)")
    }
    
    func TRACE(_ message: String = "", fun: String = #function) {
        /*
         let names = fun.components(separatedBy: ":")
         var prettyName: String
         if names.count == 2 {
             prettyName = names[0]
         } else {
             prettyName = names[1]
         }
         
         if fun == "mqttDidDisconnect(_:withError:)" {
             prettyName = "didDisconnect"
         }

         print("[TRACE] [\(prettyName)]: \(message)")
         */
    }
}


// MARK: - Helper Functions

extension GameCommunication {
    
    func convertToDictionary(stringPlayers: String) -> [String : [String]] {
        let strArray = stringPlayers.split(separator: "]")
        let strArrayCount = strArray.count
        
        var keyArrays: [String] = []
        var arrayArrays: [[String]] = []

        var dictionary: [String : [String]] = [:]
        
        for key in 0 ..< strArrayCount {
            let str1WithoutClosingBrace = strArray[key]
            let firstDic = str1WithoutClosingBrace + String("]")

            let firstKey = firstDic.split(separator: ":")[0]
            let firstKeyInt = firstKey.replacingOccurrences(of: "[", with: "")
            let firstKeyInt1 = firstKeyInt.replacingOccurrences(of: "\"", with: "")
            let firstKeyInt2 = firstKeyInt1.replacingOccurrences(of: ",", with: "")
            let firstKeyInt3 = firstKeyInt2.replacingOccurrences(of: " ", with: "")
            
            let firstArr = firstDic.split(separator: ":")[1]
            let actualArr = convertStringPlayersToArray(from: String(firstArr))

            keyArrays.append(firstKeyInt3)
            arrayArrays.append(actualArr)
        }

        for i in 0 ..< arrayArrays.count {
            dictionary[keyArrays[i]] = arrayArrays[i]
        }

        return dictionary
    }
    
    
    func convertStringPlayersToArray(from players: String) -> [String] {
        let swiftyString = players.replacingOccurrences(of: "[", with: "")
        let swiftyString1 = swiftyString.replacingOccurrences(of: "]", with: "")
        let swiftyString2 = swiftyString1.replacingOccurrences(of: "\"", with: "")
        let swiftyString3 = swiftyString2.replacingOccurrences(of: " ", with: "")

        let arr = swiftyString3.split(separator: ",")
        let arr1 = arr.map { String($0) }
        
        return arr1
    }
    
    
    func convertStringBendersToArray(from benders: String) -> [Int] {
        let swiftyString = benders.replacingOccurrences(of: "[", with: "")
        let swiftyString1 = swiftyString.replacingOccurrences(of: "]", with: "")
        let swiftyString2 = swiftyString1.replacingOccurrences(of: "\"", with: "")
        let swiftyString3 = swiftyString2.replacingOccurrences(of: " ", with: "")

        let arr = swiftyString3.split(separator: ",")
        let arr1 = arr.map { Int($0)! }
        
        return arr1
    }
}


extension Optional {
    
    // Unwrap optional value for printing only
    var description: String {
        if let self = self {
            return "\(self)"
        }
        return ""
    }
}


extension GameCommunication: Equatable {
    
    static func == (lhs: GameCommunication, rhs: GameCommunication) -> Bool {
        return lhs.player.playerCode == rhs.player.playerCode
    }
}
