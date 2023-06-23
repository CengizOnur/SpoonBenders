//
//  CustomTextField.swift
//  Spoon Benders
//
//  Created by Con Dog on 2.03.2022.
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
        layer.borderColor = UIColor.systemGray4.cgColor
        autocapitalizationType = .none
        textColor = .white
        tintColor = .label
        textAlignment = .center
        font = UIFont.preferredFont(forTextStyle: .title2)
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
