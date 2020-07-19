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
		
		let defaults = UserDefaults.standard

		let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
		
		if !defaults.bool(forKey: "LOGGED_IN") {
				defaults.set(true, forKey: "LOGGED_IN")
		}
		
		// setup our custom view controllers
		let user = Auth.auth().currentUser
		if let user = user {
			let roomNavController = createLobbyNC(user: user)
			let homeNavController = createHomeNC(user: user)
			let profileNavController = createProfileNC(user: user)
//			let settingsNavController = createSettingsNC(user: user)
//			let boardNavController = createBoardNC(user: user)
//			viewControllers = [roomNavController, boardNavController, homeNavController, profileNavController, settingsNavController]
			viewControllers = [roomNavController, homeNavController, profileNavController]
			self.tabBar.tintColor = .black
			self.selectedIndex = 1
		}
	}
	
}

extension TabBarController {
	
	func createHomeNC(user: User) -> UINavigationController {
		let homeVC = HomeVC(user: user)
		homeVC.title = "Home"
		homeVC.tabBarItem = UITabBarItem(title: homeVC.title, image: UIImage(systemName: "house.fill"), tag: 2)
		
		return NavigationController(homeVC)
	}
	
	func createLobbyNC(user: User) -> UINavigationController {
		let roomVC = LobbyVC(user: user)
		roomVC.title = "Lobby"
		roomVC.tabBarItem = UITabBarItem(title: roomVC.title, image: UIImage(systemName: "bubble.left.and.bubble.right.fill"), tag: 0)
		
		return NavigationController(roomVC)
	}
	
	func createProfileNC(user: User) -> UINavigationController {
		let profileVC = ProfileVC(user: user)
		profileVC.title = "Settings"
		profileVC.tabBarItem = UITabBarItem(title: profileVC.title, image: UIImage(systemName: "person.crop.circle.fill"), tag: 3)
		
		return NavigationController(profileVC)
	}
	
	func createBoardNC(user: User) -> UINavigationController {
		let boardVC = BoardVC(user: user)
		boardVC.title = "Board"
		boardVC.tabBarItem = UITabBarItem(title: boardVC.title, image: UIImage(systemName: "rosette"), tag: 1)
		
		return NavigationController(boardVC)
	}
	
	func createSettingsNC(user: User) -> UINavigationController {
		let settingsVC = SettingsVC(user: user)
		settingsVC.title = "Settings"
		settingsVC.tabBarItem = UITabBarItem(title: settingsVC.title, image: UIImage(systemName: "gear"), tag: 4)
		
		return NavigationController(settingsVC)
	}
}
