//
//  NavigationController.swift
//  Polink
//
//  Created by Josh Valdivia on 18/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
	
	init(_ rootVC: UIViewController) {
		super.init(nibName: nil, bundle: nil)
		pushViewController(rootVC, animated: false)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationBar.tintColor = .black
		navigationBar.prefersLargeTitles = true
		navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
		navigationBar.largeTitleTextAttributes = navigationBar.titleTextAttributes
		
	}
	
	override var shouldAutorotate: Bool {
		return false
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return topViewController?.preferredStatusBarStyle ?? .default
	}
	
}
