//
//  BenderCell.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 2.02.2022.
//

import UIKit

final class BenderCell: UICollectionViewCell {
    
    static let reuseID = "BenderCell"
    
    let benderImageView = CustomImageView(borderShape: .squircle)
    private let label = CustomLabel(textAlignment: .center)
    private let health = UIProgressView(progressViewStyle: .default)
    
    var currentHealth = 60
    var fullHealth = 100
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        contentView.addSubview(benderImageView)
        contentView.addSubview(health)
        contentView.addSubview(label)
        
        benderImageView.translatesAutoresizingMaskIntoConstraints = false
        health.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        health.progressTintColor = .systemIndigo
        health.trackTintColor = .systemPink
        label.backgroundColor = .clear
        
        let healthBottomConstraint = health.bottomAnchor.constraint(equalTo: bottomAnchor)
        healthBottomConstraint.priority = UILayoutPriority(999)
        
        let imageTrailingConstraint = benderImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
        imageTrailingConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            benderImageView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            benderImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            imageTrailingConstraint,
            benderImageView.bottomAnchor.constraint(equalTo: health.topAnchor, constant: -2),
            
            health.heightAnchor.constraint(equalToConstant: 16),
            health.widthAnchor.constraint(equalTo: widthAnchor),
            health.centerXAnchor.constraint(equalTo: benderImageView.centerXAnchor),
            healthBottomConstraint,
            
            label.centerXAnchor.constraint(equalTo: health.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: health.centerYAnchor),
            label.heightAnchor.constraint(equalTo: health.heightAnchor, constant: -2)
        ])
    }
    
    
    // MARK: - Set and Update Bender on Cell
    
    func setAndUpdateBenderOnCell(bender: Bender, benderPosition: BenderPosition) {
        benderImageView.stopAnimating()
        benderImageView.animationImages = animatedImages(for: bender.imageName, state: bender.state, benderPosition: benderPosition)
        benderImageView.animationDuration = 1.1
        benderImageView.animationRepeatCount = 0
        benderImageView.image = benderImageView.animationImages?.first
        benderImageView.startAnimating()
        currentHealth = bender.health > 0 ? bender.health : 0
        fullHealth = bender.fullHealth
        health.progress = (Float(currentHealth) / Float(fullHealth))
        label.text = "\(Int(currentHealth))"
    }
    
    
    func animatedImages(for benderImageName: String, state: BenderState, benderPosition: BenderPosition) -> [UIImage] {
        var images = [UIImage]()
        let stateCapitalized = "\(state)".firstUppercased
        let benderPositionCapitalized = "\(benderPosition)".firstUppercased
        let imageName = "\(benderImageName)\(benderPositionCapitalized)/\(benderImageName)\(stateCapitalized)\(benderPositionCapitalized)"
        var i = 1
        while let image = UIImage(named: "\(imageName)\(i)") {
            images.append(image)
            i += 1
        }
        return images
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("BenderCell is deallocated")
    }
}
