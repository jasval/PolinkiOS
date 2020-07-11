//
//  PopupDismissalAnimationController.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class PopupDismissalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let overlayView: UIView?
	
	init(overlayView: UIView?) {
		self.overlayView = overlayView
	}
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.6
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		guard let fromVC = transitionContext.viewController(forKey: .from),
			let toVC = transitionContext.viewController(forKey: .to) else {
				return
		}
		
		let fromVCFrame = transitionContext.initialFrame(for: fromVC)
		let toVCFrame = transitionContext.finalFrame(for: toVC)
		let duration = transitionDuration(using: transitionContext)
		let scaleTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
		let translateTransform = CGAffineTransform(translationX: 0.0, y: toVCFrame.height - fromVCFrame.origin.y)
		
		UIView.animate(withDuration: duration,
							delay: 0.0,
							usingSpringWithDamping: 0.8,
							initialSpringVelocity: 0.4,
							options: .curveLinear,
							animations: {
								
								self.overlayView?.alpha = 0.0
								fromVC.view.transform = scaleTransform.concatenating(translateTransform)
								
		}) { (_) in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}
}
