//
//  AppDelegate.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Configure Firebase and Firestore extensions.
		FirebaseApp.configure()
		let db = Firestore.firestore()
		print(db)
		
		// Get the path for the user defaults path
		print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
		
//		UserDefaults.standard.set(false, forKey: "LOGGED_IN")
		
		return true
	}
	
	// MARK: UISceneSession Lifecycle
	
	func applicationWillResignActive(_ application: UIApplication) {
		print("Application will resign")
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		print("Application did enter background")
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		print("Application will enter foreground")
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		print("Application did become active")
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		print("Application will terminate")
	}
	
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
}
