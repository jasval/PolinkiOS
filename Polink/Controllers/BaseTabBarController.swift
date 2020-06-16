//
//  BaseTabBarController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class BaseTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup our custom view controllers
        let user = Auth.auth().currentUser
        let roomController = RoomsViewController(currentUser: user!)
        let lobbyNavController = UINavigationController(rootViewController: roomController)
        lobbyNavController.tabBarItem.title = "Lobby"
        
        viewControllers = [lobbyNavController]
    }
}
