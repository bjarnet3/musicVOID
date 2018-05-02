//
//  Functions.swift
//  musicVOID
//
//  Created by Bjarne Tvedten on 28.04.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

// Haptic Engine Types
enum HapticEngineTypes {
    case error, success, warning, light, medium, heavy, selection
}

/// Haptic Engine Effects
func hapticButton(_ types: HapticEngineTypes) {
    switch types {
    case .error:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    case .success:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    case .warning:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    case .light:
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    case .medium:
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    case .heavy:
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    default:
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

/// argument **String** of **#HEX** returns **UIColor** value
func hexStringToUIColor (_ hex:String, _ alpha: Float = 1.0) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines as NSCharacterSet) as CharacterSet).uppercased()
    
    if (cString.hasPrefix("#")) {
        // let index: String.Index = cString.index(cString.startIndex, offsetBy: 1)
        // cString = cString.substring(from: index) // "Stack"
        cString.removeFirst()// String(cString[index...cString.endIndex])
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha)
    )
}

/// animate view (parallax Effect)
func addParallaxEffectOnView(_ view: UIView, _ relativeMotionValue: Int) {
    let relativeMotionValue = relativeMotionValue
    let verticalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                                                         type: .tiltAlongVerticalAxis)
    verticalMotionEffect.minimumRelativeValue = -relativeMotionValue
    verticalMotionEffect.maximumRelativeValue = relativeMotionValue
    
    let horizontalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                                           type: .tiltAlongHorizontalAxis)
    horizontalMotionEffect.minimumRelativeValue = -relativeMotionValue
    horizontalMotionEffect.maximumRelativeValue = relativeMotionValue
    
    let group : UIMotionEffectGroup = UIMotionEffectGroup()
    group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
    
    view.addMotionEffect(group)
}

func removeParallaxEffectOnView(_ view: UIView) {
    let motionEffects = view.motionEffects
    for motion in motionEffects {
        view.removeMotionEffect(motion)
    }
}

extension MutableCollection {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
    }
}
