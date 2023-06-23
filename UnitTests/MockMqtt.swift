//
//  MockMqtt.swift
//  UnitTests
//
//  Created by con akd on 6.07.2022.
//

@testable import Spoon_Benders
@testable import CocoaMQTT

class MockMqtt: MqttProtocol {
    
    var username: String?
    var password: String?
    var keepAlive: UInt16 = 60
    var willMessage: CocoaMQTTMessage?
    
    var delegate: CocoaMQTTDelegate?
    
    var broker: MockMqttBroker
    
    init(broker: MockMqttBroker) {
        self.broker = broker
    }
    
    
    func connect() -> Bool {
        if let subscriber = delegate {
            broker.subscribe(subscriber: subscriber)
            return true
        }
        return false
    }
    
    
    func disconnect() {
        if let subscriber = delegate {
            broker.unsubscribe(subscriber: subscriber)
        }
    }
    
    
    func publish(_ topic: String, withString string: String, qos: CocoaMQTTQoS = .qos1, retained: Bool = false) -> Int {
//        print("🤣🤣🤣🤣🤣\(string)")
        broker.latestPublishedMessage = CocoaMQTTMessage(topic: topic, string: string)
        broker.sendLatestPublishedMessage()
        return 0
    }
    
    
    //
    func publish(_ message: CocoaMQTTMessage) -> Int {
//        print("🤣🤣🤣🤣🤣\(message.payload)")
        broker.latestPublishedMessage = message
        broker.sendLatestPublishedMessage()
        return 0
    }
}


class MockMqttBroker {
    
    private(set) var subscribers: [CocoaMQTTDelegate?] = []
    var latestPublishedMessage: CocoaMQTTMessage?
    
    func subscribe(subscriber: CocoaMQTTDelegate) {
        subscribers.append(subscriber)
        if let subscriber = subscriber as? GameCommunication {
            subscriber.declareSubscription()
        }
    }
    
    
    func unsubscribe(subscriber: CocoaMQTTDelegate) {
        let indexOfSubscriber = subscribers.firstIndex{ $0 as? GameCommunication == subscriber as? GameCommunication }
        if let indexOfSubscriber = indexOfSubscriber {
            subscribers.remove(at: indexOfSubscriber)
        }
    }
    
    
    func sendLatestPublishedMessage() {
        subscribers.forEach { subscriber in
            if let message = latestPublishedMessage,
               let subscriber = subscriber as? GameCommunication {
                subscriber.messageDistributor(message: message)
            }
        }
    }
    
}


extension CocoaMQTTDelegate {
    func isCommunicationManager() -> GameCommunication? {
        if let self = self as? GameCommunication {
            return self
        }
        return nil
    }
}


/*
 func sendLatestPublishedMessage(sender: CocoaMQTTDelegate) {
     subscribers.forEach { subscriber in
         if let message = latestPublishedMessage {
             if let subscriber = subscriber as? CommunicationManager {
                 subscriber.messageDistributor(message: message)
                 if subscriber == sender as! CommunicationManager ||
                     message.string == "Disconnected:\(subscriber.player.playerCode)" {
                     subscriber.disconnect()
                 }
             }
         }
     }
 }
 */


/*
 delegate?.mqtt((self as MqttProtocol) as! CocoaMQTT, didReceiveMessage: CocoaMQTTMessage(topic: topic, string: string), id: 8)
 */
