//
//  GameMode+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 26.06.2023.
//

extension GameMode {
    
    var convertToString: String {
        switch self {
        case .oneVsOne:
            return "1v1"
        case .twoVsTwo:
            return "2v2"
        case .ffa:
            return "FFA"
        }
    }
    
    var convertToInt: Int {
        switch self {
        case .oneVsOne:
            return 2
        case .twoVsTwo:
            return 4
        default:
            /// case .ffa:
            return 4
        }
    }
}
