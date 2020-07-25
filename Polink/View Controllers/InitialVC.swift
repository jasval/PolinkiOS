//
//  InitialVC.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class InitialVC: UIViewController {

	@IBOutlet var buttons: [UIButton]!
	@IBOutlet weak var mainTitleLabel: UILabel!
	
	var regVC: UIViewController?
	var quizVC: UIViewController?
	
	// Creating an instance of the user defaults
	let defaults = UserDefaults.standard
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		mainTitleLabel.alpha = 0
		mainTitleLabel.text = K.appName
		for button in buttons {
			button.layer.masksToBounds = true
			button.layer.cornerRadius = button.frame.height / 5
			button.alpha = 0
		}
		
		let regSB = UIStoryboard(name: "Registration", bundle: nil)
		let quizSB = UIStoryboard(name: "Quiz", bundle: nil)
		regVC = regSB.instantiateViewController(withIdentifier: "RegistrationController")
		quizVC = quizSB.instantiateViewController(withIdentifier: "QuizVC")
		
		navigationController?.viewControllers.append(contentsOf: [regVC!, quizVC!])
		navigationController?.popToRootViewController(animated: false)

		
	}
	override func viewWillAppear(_ animated: Bool) {
	}
	
	override func viewDidAppear(_ animated: Bool) {
		// Call extension of UIViewController function
		animateIn(mainTitleLabel, delay: 0)
		for button in buttons {
			animateIn(button, delay: 1)
		}
	}
	
	// Actions performed
	@IBAction func signUpPressed(_ sender: Any) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "registerViewController") as! SignUpVC
		vc.registerDelegate = self
		self.present(vc, animated: true)
	}
	
	@IBAction func signInPressed(_ sender: Any) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "loginViewController")
		self.present(vc, animated: true)
	}
	

}

// MARK: - Delegates
// This will probably will be changed to a notification system but for the time being it works

extension InitialVC: RegisterDelegate {
	func didTapToRegister() {
		navigationController?.pushViewController(regVC!, animated: true)
	}
}

extension InitialVC: LoginDelegate {
	func userIsIncomplete() {
		didTapToRegister()
	}
}
