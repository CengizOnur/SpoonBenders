//
//  CustomTextField.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 2.03.2022.
//

import UIKit

final class CustomTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        returnKeyType = .join
        layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        rightViewMode = .always
        autocapitalizationType = .none
        textColor = .white
        tintColor = .white
        textAlignment = .center
        font = UIFont(name: "Poultrygeist", size: 24)
        adjustsFontSizeToFitWidth = true
        minimumFontSize = 12
        backgroundColor = .black.withAlphaComponent(0.5)
        attributedPlaceholder = NSAttributedString(
            string: "placeholder",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        autocorrectionType = .no
        
        layer.cornerRadius = 10
        layer.borderWidth = 2
        
        if #unavailable(iOS 15.0) {
            let item = self.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
    }
}
