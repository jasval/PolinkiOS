//
//  BaseTabBarController.swift
//  polink.dev
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    @IBInspectable var defaultIndex: Int = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
}
