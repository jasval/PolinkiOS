//
//  TabBarController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup our custom view controllers
		let user = Auth.auth().currentUser
		let roomNavController = createRoomNC(user: user)
		let homeNavController = createHomeNC()
		let profileNavController = createProfileNC()
		let settingsNavController = createSettingsNC()
		let boardNavController = createBoardNC()
		
		viewControllers = [roomNavController, boardNavController, homeNavController, profileNavController, settingsNavController]
		self.selectedIndex = 2
	}
}

extension TabBarController {
	
	func createHomeNC() -> UINavigationController {
		let homeVC = HomeVC()
		homeVC.title = "Home"
		homeVC.tabBarItem = UITabBarItem(title: homeVC.title, image: UIImage(systemName: "house.fill"), tag: 2)
		
		return UINavigationController(rootViewController: homeVC)
	}
	
	func createRoomNC(user: User?) -> UINavigationController {
		let roomVC = LobbyVC(currentUser: user!)
		roomVC.title = "Lobby"
		roomVC.tabBarItem = UITabBarItem(title: roomVC.title, image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 0)
		
		return UINavigationController(rootViewController: roomVC)
	}
	
	func createProfileNC() -> UINavigationController {
		let profileVC = ProfileVC()
		profileVC.title = "Profile"
		profileVC.tabBarItem = UITabBarItem(title: profileVC.title, image: UIImage(systemName: "person.crop.circle.fill"), tag: 3)
		
		return UINavigationController(rootViewController: profileVC)
	}
	
	func createBoardNC() -> UINavigationController {
		let boardVC = BoardVC()
		boardVC.title = "Board"
		boardVC.tabBarItem = UITabBarItem(title: boardVC.title, image: UIImage(systemName: "rosette"), tag: 1)
		
		return UINavigationController(rootViewController: boardVC)
	}
	
	func createSettingsNC() -> UINavigationController {
		let settingsVC = SettingsVC()
		settingsVC.title = "Settings"
		settingsVC.tabBarItem = UITabBarItem(title: settingsVC.title, image: UIImage(systemName: "gear"), tag: 4)
		
		return UINavigationController(rootViewController: settingsVC)
	}
	
	func createTabBar(user: User?) -> UITabBarController {
		let tabbar = UITabBarController()
		UITabBar.appearance().tintColor = .systemGreen
		tabbar.viewControllers = [createHomeNC(), createRoomNC(user: user)]
		return tabbar
	}
}
