//
//  OldAppearance.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

struct OldAppearance {
	static let cornerRadius: CGFloat = 8.0
	static let cornerRadiusBig: CGFloat = 25.0
	static let padding: CGFloat = 16.0
	static let cellVerticalPadding: CGFloat = 10.0
	static let separatorThickHeight: CGFloat = 8.0
	static let preferredCompactWidth: CGFloat = 295.0
	static let preferredRegularWidth: CGFloat = 560.0
	
	static func applyCardShadow(_ layer: CALayer) {
		layer.shadowOpacity = 0.6
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
		layer.shadowRadius = 5.0
	}
	
	static func preferredWidth(for traitCollection: UITraitCollection) -> CGFloat {
		switch traitCollection.horizontalSizeClass {
		case .regular:
			return preferredRegularWidth
		default:
			return preferredCompactWidth
		}
	}
	
	static func setupUiAppearance(in window: UIWindow) {
		
		window.overrideUserInterfaceStyle = .dark
		window.tintColor = .gray
				
		UINavigationBar.appearance().barStyle = UIBarStyle.black
		UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Trim-Regular", size: 20)!,
																			  NSAttributedString.Key.kern: NSNumber(0.3)]
		UINavigationBar.appearance().largeTitleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Trim-Medium", size: 32)!,
																					 NSAttributedString.Key.kern: NSNumber(0.3)]
		UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Trim-Regular", size: 17)!],
																			 for: .normal)
		UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Trim-Regular", size: 17)!],
																			 for: .highlighted)
		UIBarButtonItem.appearance().setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "Trim-Regular", size: 17)!],
																			 for: .disabled)
		
		UITabBar.appearance().barStyle = .black
	}
}
