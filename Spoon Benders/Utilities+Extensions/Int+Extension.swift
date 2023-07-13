//
//  Int+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 4.01.2023.
//

import Foundation

extension Int {
    
    var throwableObjectType: ThrowableObjectType {
        switch self {
        case 0:
            return .spoon
        case 1:
            return .pumpkinGhost
        case 2:
            return .bat
        default:
            return .spoon
        }
    }
    
    static var randomNumber: Int {
        let randomNumber = Int.random(in: 100..<999)
        return randomNumber
    }
    
    
    static func randomNumbers(from: Int, to: Int) -> [Int] {
        var arrayNumbers = [Int]()
        while arrayNumbers.count < 3 {
            let randomNumber = Int.random(in: from ... to)
            if arrayNumbers.contains(randomNumber) == false {
                arrayNumbers.append(randomNumber)
            }
        }
        return arrayNumbers
    }
}
