//
//  Int+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 4.01.2023.
//

import Foundation

extension Int {
    
    static var randomCode: String {
        let randomNumber = Int.random(in: 100..<200)
        return String(randomNumber)
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
