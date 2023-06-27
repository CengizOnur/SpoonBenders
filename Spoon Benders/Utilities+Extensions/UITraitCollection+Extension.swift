//
//  UITraitCollection+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 25.06.2023.
//

import UIKit

// MARK: - Using for Different Size Classes on TextFields, Buttons etc.

extension UITraitCollection {
    
    var constantBySizeClass: CGFloat {
        if horizontalSizeClass == .compact
            || verticalSizeClass == .compact {
            return 4
        } else {
            return 6
        }
    }
    
    var spaceBySizeClass: CGFloat {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return 56
        default:
            return 8
        }
    }
    
    var fontSizeBySizeClass: CGFloat {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return 56
        default:
            return 32
        }
    }
    
    
    func coefficientOfPlayerView(orientation: Orientation) -> CGFloat {
        switch (orientation, (self.horizontalSizeClass, self.verticalSizeClass)) {
        case (.portrait, (.regular, .regular)):
            return 0.15
        case (.landscape, (.regular, .regular)):
            return 0.2
        case (.portrait, (_, _)):
            return 0.18
        default:
            /// case (.landscape, (_, _)):
            return 0.25
        }
    }
}
