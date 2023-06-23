//
//  String+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 4.01.2023.
//

import Foundation
import UIKit

// MARK: - Convert String to GameMode

extension String {
    
    var convertToGameMode: GameMode {
        switch self {
        case "1", "1v1":
            return .oneVsOne
        case "2", "2v2":
            return .twoVsTwo
        case "A", "FFA":
            return .ffa
        default:
            return .oneVsOne
        }
    }
}


// MARK: - Convert string to UIImage

extension String {
    
    func image(fontSize:CGFloat = 40, bgColor:UIColor = UIColor.clear, imageSize:CGSize? = nil) -> UIImage? {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedString.Key.font: font]
        let imageSize = imageSize ?? self.size(withAttributes: attributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        bgColor.set()
        let rect = CGRect(origin: .zero, size: imageSize)
        UIRectFill(rect)
        self.draw(in: rect, withAttributes: [.font: font])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


// MARK: - Capitalize First Letter

extension StringProtocol {
    
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
