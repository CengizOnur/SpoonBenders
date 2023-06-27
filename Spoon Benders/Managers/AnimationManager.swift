//
//  AnimationManager.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 13.03.2022.
//

import Foundation
import UIKit

protocol AnimationManagerDelegate: AnyObject {
    
    func finishedAnimation(by player: String, duelType: DuelType)
}


final class AnimationManager: NSObject, CAAnimationDelegate {
    
    weak var animator: AnimationManagerDelegate?
    
    
    // MARK: - Spoon moves from attacker benders position to defender benders position
    
    func throwSpoon(by player: String, from: CGPoint, to: CGPoint, spoon: UIView, duelType: DuelType) {
        let animation = CABasicAnimation(keyPath: "position")
        
        rotateSpoon(imageView: spoon as! UIImageView, aCircleTime: 0.5)
        
        animation.fromValue = from
        animation.toValue = to
        
        animation.duration = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        animation.delegate = self
        
        animation.setValue(player, forKey: "attackAnimation.player")
        animation.setValue(from, forKey: "attackAnimation.from")
        animation.setValue(to, forKey: "attackAnimation.to")
        animation.setValue(spoon, forKey: "attackAnimation.spoon")
        animation.setValue(spoon.layer, forKey: "attackAnimation.layer")
        animation.setValue(duelType, forKey: "attackAnimation.duelType")
        
        spoon.layer.add(animation, forKey: "attackAnimation.animation")
    }
    
    
    // MARK: - Spoon rotates while it is moving
    
    private func rotateSpoon(imageView: UIImageView, aCircleTime: Double) {
        UIView.animate(withDuration: aCircleTime/2, delay: 0.0, options: .curveLinear, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: { [weak self] finished in
            UIView.animate(withDuration: aCircleTime/2, delay: 0.0, options: .curveLinear, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: .pi*2)
            }, completion: { finished in
                self?.rotateSpoon(imageView: imageView, aCircleTime: aCircleTime)
            })
        })
    }
    
    
    // MARK: - Benders Health Decreasing After Attack
    
    func decreaseHealth(from: CGPoint, to: CGPoint, spoon: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        
        animation.fromValue = from
        animation.toValue = to
        
        animation.duration = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        animation.delegate = self
        
        animation.setValue(from, forKey: "attackAnimation.from")
        animation.setValue(to, forKey: "attackAnimation.to")
        animation.setValue(spoon, forKey: "decreasingHealthAnimation.health")
        animation.setValue(spoon.layer, forKey: "attackAnimation.layer")
        
        spoon.layer.add(animation, forKey: "attackAnimation.animation")
    }
    
    
    // MARK: - When animation finished
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if let _ = anim.value(forKey: "attackAnimation.spoon") as? UIView {
            finishedThrowingAnimation(anim)
        } else if let _ = anim.value(forKey: "decreasingHealthAnimation.health") as? UIView {
            finishedDecreasingHealthAnimation(anim)
        }
    }
    
    
    // MARK: - Handle Animation Results
    
    func finishedThrowingAnimation(_ anim: CAAnimation) {
        let spoon = anim.value(forKey: "attackAnimation.spoon") as! UIView
        spoon.removeFromSuperview()
        let layer = anim.value(forKey: "attackAnimation.layer") as! CALayer
        layer.removeFromSuperlayer()
        
        let player = anim.value(forKey: "attackAnimation.player") as! String
        let duelType = anim.value(forKey: "attackAnimation.duelType") as! DuelType
        
        animator?.finishedAnimation(by: player, duelType: duelType)
    }
    
    
    func finishedDecreasingHealthAnimation(_ anim: CAAnimation) {
        let spoon = anim.value(forKey: "decreasingHealthAnimation.health") as! UIView
        spoon.removeFromSuperview()
        let layer = anim.value(forKey: "attackAnimation.layer") as! CALayer
        layer.removeFromSuperlayer()
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("AnimationManager is deallocated")
    }
}
