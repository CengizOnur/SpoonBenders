//
//  CustomImageView.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 17.11.2022.
//

import UIKit

enum BorderShape: String {
    case circle
    case squircle
}


final class CustomImageView: UIImageView {
    
    private let borderShape: BorderShape
    
    
    init(borderShape: BorderShape) {
        self.borderShape = borderShape
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    
    private func commonInit() {
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFit
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        clipsToBounds = true
    }
    
    
    private func setupBorderShape() {
        layer.borderWidth = 2.5
        let width = frame.size.width
        let divisor: CGFloat
        
        if borderShape == .circle {
            layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35).cgColor
            divisor = 2
        } else {
            divisor = 8
        }
        
        let cornerRadius = width / divisor
        layer.cornerRadius = cornerRadius
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBorderShape()
    }
}
