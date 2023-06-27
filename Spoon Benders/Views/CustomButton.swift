//
//  CustomButton.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 2.03.2022.
//

import UIKit

final class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(backgroundColor: UIColor, title: String) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
    }
    
    
    convenience init(backgroundColor: UIColor, title: String?, image: UIImage?, imageSize: CGFloat = 24) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
        self.updateButton(with: image, tintColor: .white, imageSize: imageSize)
    }
    
    
    convenience init(backgroundColor: UIColor, backgroundImage: UIImage, title: String) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setBackgroundImage(backgroundImage, for: .normal)
        self.setTitle(title, for: .normal)
    }
    
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 10
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: "Poultrygeist", size: 24)
    }
    
    
    func updateButton(with newImage: UIImage?, tintColor: UIColor, imageSize: CGFloat = 24) {
        let imageFont = UIFont.systemFont(ofSize: imageSize)
        let configuration = UIImage.SymbolConfiguration(font: imageFont)
        let image = newImage?.withConfiguration(configuration)
        setImage(image, for: .normal)
        self.tintColor = tintColor
    }
}
