//
//  PresentationAnimationController.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class PopupPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	let overlayView: UIView
	
	override init() {
		overlayView = UIView()
		overlayView.backgroundColor = .black
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		guard let fromVC = transitionContext.viewController(forKey: .from),
			let toVC = transitionContext.viewController(forKey: .to) else {
				return
		}
		
		let containerView = transitionContext.containerView
		
		let initialFrame = transitionContext.initialFrame(for: fromVC)
		
		let preferredWidth = Appearance.preferredWidth(for: toVC.traitCollection)
		let finalWidth = min(initialFrame.width - 2.0 * Appearance.padding, preferredWidth)
		let finalHeight = min(initialFrame.height - 2.0 * Appearance.padding, 500.0)
		let finalFrame = CGRect(x: initialFrame.origin.x + (initialFrame.width - finalWidth) / 2.0,
										y: initialFrame.origin.y + (initialFrame.height - finalHeight) / 2.0,
										width: finalWidth,
										height: finalHeight)
		
		toVC.view.frame = finalFrame
		toVC.view.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
		toVC.view.layer.cornerRadius = Appearance.cornerRadius
		toVC.view.clipsToBounds = true
		overlayView.frame = initialFrame
		containerView.addSubview(overlayView)
		containerView.addSubview(toVC.view)
		
		let duration = transitionDuration(using: transitionContext)
		
		overlayView.alpha = 0.0
		
		let scaleTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
		let translateTransform = CGAffineTransform(translationX: 0.0, y: -initialFrame.height)
		toVC.view.transform = scaleTransform.concatenating(translateTransform)
		
		UIView.animate(withDuration: duration,
							delay: 0.0,
							usingSpringWithDamping: 0.8,
							initialSpringVelocity: 4.0,
							options: .curveLinear,
							animations: {
								
								self.overlayView.alpha = 0.4
								toVC.view.transform = CGAffineTransform.identity
								
		}) { (_) in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}
}
