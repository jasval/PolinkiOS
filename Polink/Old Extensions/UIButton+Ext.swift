//
//  UIButton+Ext.swift
//  Polink
//
//  Created by Jose Saldana on 30/05/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

// Extensions for adding animations to UIButtons

extension UIButton {
	func pulsate() {
		let pulse = CASpringAnimation(keyPath: "transform.scale")
		pulse.duration = 0.2
		pulse.fromValue = 1
		pulse.toValue = 1.1
		pulse.autoreverses = true
		pulse.repeatCount = 0
		pulse.initialVelocity = 0.5
		pulse.damping = 1.0
		
		layer.add(pulse, forKey: nil)
	}
	func shake() {
		let shake = CABasicAnimation(keyPath: "position")
		shake.duration = 1
		shake.repeatCount = 30
		shake.autoreverses = true
		
		let fromPoint =  CGPoint(x: center.x, y: center.y)
		let fromValue = NSValue(cgPoint: fromPoint)
		
		let toPoint = CGPoint(x: center.x + 10, y: center.y)
		let toValue = NSValue(cgPoint: toPoint)
		
		shake.fromValue = fromValue
		shake.toValue = toValue
		
		layer.add(shake, forKey: nil)
	}
}
