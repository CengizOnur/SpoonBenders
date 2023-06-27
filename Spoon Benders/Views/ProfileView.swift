//
//  ProfileView.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 19.05.2022.
//

import UIKit

enum NicknameView {
    case label
    case textField
}


final class ProfileView: UIView {
    
    let avatarImageView = CustomImageView(borderShape: .circle)
    var nicknameLabelOrField: UIView!
    
    lazy var fontSize = 32.0
    
    init(nicknameView: NicknameView = .label, ratioOfnicknameViewToAvatar: Double = 0, labelFont: UIFont? = UIFont(name: "Poultrygeist", size: 12)) {
        super.init(frame: CGRect.zero)
        configure(with: nicknameView, by: ratioOfnicknameViewToAvatar, labelFont: labelFont)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - ConfigureUI
    
    private func configure(with nicknameView: NicknameView, by ratioOfnicknameViewToAvatar: Double, labelFont: UIFont?) {
        if nicknameView == .label {
            nicknameLabelOrField = CustomLabel(textAlignment: .center, font: labelFont)
            (nicknameLabelOrField as! CustomLabel).minimumScaleFactor = 0.3
        } else {
            nicknameLabelOrField = CustomTextField()
        }
        
        addSubview(avatarImageView)
        addSubview(nicknameLabelOrField)
        
        translatesAutoresizingMaskIntoConstraints = false
        nicknameLabelOrField.translatesAutoresizingMaskIntoConstraints = false
        
        let padding: CGFloat = 5
        
        let imageLeading = avatarImageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        imageLeading.priority = .defaultHigh
        
        let imageTrailing = avatarImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        imageTrailing.priority = .defaultHigh
        
        var nicknameLabelOrFieldHeight: NSLayoutConstraint
        
        if ratioOfnicknameViewToAvatar == 0 {
            nicknameLabelOrFieldHeight = nicknameLabelOrField.heightAnchor.constraint(lessThanOrEqualToConstant: 48)
        } else {
            nicknameLabelOrFieldHeight = nicknameLabelOrField.heightAnchor.constraint(equalTo: avatarImageView.heightAnchor, multiplier: ratioOfnicknameViewToAvatar)
        }
        
        NSLayoutConstraint.activate([
            nicknameLabelOrField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            nicknameLabelOrFieldHeight,
            
            avatarImageView.bottomAnchor.constraint(equalTo: nicknameLabelOrField.topAnchor, constant: -padding),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            nicknameLabelOrField.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nicknameLabelOrField.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
        ])
    }
}
