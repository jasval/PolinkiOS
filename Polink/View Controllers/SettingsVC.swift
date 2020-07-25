//
//  SettingsVC.swift
//  Polink
//
//  Created by Josh Valdivia on 18/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {
	
	private let currentUser: User
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .orange
		// Do any additional setup after loading the view.
	}
	
	init(user: User) {
		self.currentUser = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
}
