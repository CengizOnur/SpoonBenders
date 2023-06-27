//
//  CustomLabel.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 19.05.2022.
//

import UIKit

final class CustomLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(textAlignment: NSTextAlignment = .center, font: UIFont? = UIFont(name: "Poultrygeist", size: 12)) {
        self.init(frame: .zero)
        self.textAlignment = textAlignment
        self.font = font
    }
    
    
    private func configure() {
        textColor = .white
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.3
        lineBreakMode = .byTruncatingTail
        numberOfLines = 3
        text = "Waiting..."
    }
}
