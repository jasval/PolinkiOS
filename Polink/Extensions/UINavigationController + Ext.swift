//
//  UINavigationController + Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 22/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
	func fadeTo(_ viewController: UIViewController) {
		let transition: CATransition = CATransition()
		transition.duration = 0.3
		transition.type = CATransitionType.fade
		view.layer.add(transition, forKey: nil)
		pushViewController(viewController, animated: false)
	}
	
	func fadeFrom() {
		let transition: CATransition = CATransition()
		transition.duration = 0.3
		transition.type = CATransitionType.fade
		view.layer.add(transition, forKey: nil)
		popViewController(animated: false)
	}
	
}
