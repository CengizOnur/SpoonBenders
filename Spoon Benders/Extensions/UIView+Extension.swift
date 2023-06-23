//
//  UIView+Extension.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 5.01.2023.
//

import Foundation
import UIKit

// MARK: - ActivityIndicator

extension UIView {
    
    func showImageLoadingView() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        
        // Set proper tag and alpha for UIView and UIImageView.
        containerView.setTagAndAlpha()
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.heightAnchor.constraint(equalTo: heightAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    
    func dismissImageLoadingView() {
        alpha = 1
        var containerViewInImageView = viewWithTag(50)
        var containerViewInView = viewWithTag(100)
        containerViewInImageView?.removeFromSuperview()
        containerViewInView?.removeFromSuperview()
        containerViewInImageView = nil
        containerViewInView = nil
    }
    
    
    func setTagAndAlpha() {
        if superview is UIImageView {
            tag = 50
            alpha = 0.5
        } else {
            tag = 100
            alpha = 0
            UIView.animate(withDuration: 0.25) { self.alpha = 0.8 }
        }
    }
    
    
    static func makeView(width: CGFloat, height: CGFloat, color: UIColor) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}


// MARK: - Gradient

extension UIView {
    
    func addGradient(gradientLayer: CAGradientLayer, colors: [UIColor]) {
        gradientLayer.type = .axial
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }
    
    
    func backgroundImage2(named: String) {
        let backgroundImage = UIImageView(frame: self.frame)
        backgroundImage.image = UIImage(named: named)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.center = self.center
        backgroundImage.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        
        self.insertSubview(backgroundImage, at: 0)
        self.sendSubviewToBack(backgroundImage)
    }
    
    
    func backgroundImage(named: String) {
        let backgroundImage = UIImageView(frame: .zero)
        backgroundImage.image = UIImage(named: named)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.insertSubview(backgroundImage, at: 0)
        self.sendSubviewToBack(backgroundImage)
    }
}


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
            return 90
        default:
            return 10
        }
    }
    
    var fontSizeBySizeClass: CGFloat {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return 48
        default:
            return 32
        }
    }
}


// MARK: - StackView Customization

extension UIStackView {
    
    func customize(backgroundColor: UIColor = .clear, radiusSize: CGFloat = 0, alpha: CGFloat = 1.0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
        
        subView.layer.cornerRadius = radiusSize
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
    }
}
