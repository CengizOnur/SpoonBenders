//
//  MqttProtocol.swift
//  Spoon Benders
//
//  Created by con akd on 6.07.2022.
//

import CocoaMQTT

protocol MqttProtocol: AnyObject {
    
    var username: String? {get set}
    var password: String? {get set}
    var keepAlive: UInt16 {get set}
    var willMessage: CocoaMQTTMessage? {get set}
    var delegate: CocoaMQTTDelegate? {get set}
    
    func connect() -> Bool
    func disconnect()
    
    @discardableResult func publish(_ topic: String, withString string: String, qos: CocoaMQTTQoS, retained: Bool) -> Int
}


extension CocoaMQTT: MqttProtocol { }
