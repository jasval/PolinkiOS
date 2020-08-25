//
//  InitialVC.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

	private var signUpButton: UIButton = {
		let button = UIButton(type: .roundedRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Sign Up", for: .normal)
		button.backgroundColor = .black
		button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		button.setTitleColor(.white, for: .normal)
		button.addTarget(self, action: #selector(signUpPressed(_:)), for: .touchUpInside)
		button.alpha = 0
		button.layer.masksToBounds = true
		button.layer.cornerRadius = 10

		return button
	}()
	
	private var signInButton: UIButton = {
		let button = UIButton(type: .roundedRect)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Sign In", for: .normal)
		button.backgroundColor = .black
		button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		button.setTitleColor(.white, for: .normal)
		button.addTarget(self, action: #selector(signInPressed(_:)), for: .touchUpInside)
		button.alpha = 0
		button.layer.masksToBounds = true
		button.layer.cornerRadius = 10
		return button
	}()
	
	private var mainTitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
		label.contentMode = .center
		label.textAlignment = .center
		label.layer.shadowColor = UIColor.lightGray.cgColor
		label.layer.shadowOffset = CGSize(width: 2, height: 2)
		label.alpha = 0
		label.text = K.appName
		return label
	}()
	
	var regVC: UIViewController?
	var quizVC: UIViewController?
	
	// Creating an instance of the user defaults
	let defaults = UserDefaults.standard
	
	init() {
		let regSB = UIStoryboard(name: "Registration", bundle: nil)
		let quizSB = UIStoryboard(name: "Quiz", bundle: nil)
		regVC = regSB.instantiateViewController(withIdentifier: "RegistrationController")
		quizVC = quizSB.instantiateViewController(withIdentifier: "QuizVC")

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		navigationController?.viewControllers.append(contentsOf: [regVC!, quizVC!])
		navigationController?.popToRootViewController(animated: false)
	}
	
	func setupViews() {
		view.backgroundColor = .white
		view.addSubview(mainTitleLabel)
		view.addSubview(signUpButton)
		view.addSubview(signInButton)
		
		NSLayoutConstraint.activate([
			mainTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
			mainTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			mainTitleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100),
			mainTitleLabel.heightAnchor.constraint(equalToConstant: 100),
			
			signUpButton.centerXAnchor.constraint(equalTo: mainTitleLabel.centerXAnchor),
			signUpButton.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 20),
			signUpButton.heightAnchor.constraint(equalToConstant: 50),
			signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
			
			signInButton.centerXAnchor.constraint(equalTo: mainTitleLabel.centerXAnchor),
			signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
			signInButton.heightAnchor.constraint(equalTo: signUpButton.heightAnchor),
			signInButton.widthAnchor.constraint(equalTo: signUpButton.widthAnchor)
		])
	}
	
	override func viewWillAppear(_ animated: Bool) {
	}
	
	override func viewDidAppear(_ animated: Bool) {
		// Call extension of UIViewController function
		animateIn(mainTitleLabel, delay: 0)
		animateIn(signInButton, delay: 1)
		animateIn(signUpButton, delay: 1)
	}
	
	// Actions performed
	@objc func signUpPressed(_ sender: Any) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "registerViewController") as! SignUpVC
		vc.registerDelegate = self
		self.present(vc, animated: true)
	}
	
	@objc func signInPressed(_ sender: Any) {
		let sb = UIStoryboard(name: "Main", bundle: nil)
		let vc = sb.instantiateViewController(withIdentifier: "loginViewController")
		self.present(vc, animated: true)
	}
	

}

// MARK: - Delegates
// This will probably will be changed to a notification system but for the time being it works

extension InitialViewController: RegisterDelegate {
	func didTapToRegister() {
		navigationController?.pushViewController(regVC!, animated: true)
	}
}

extension InitialViewController: LoginDelegate {
	func userIsIncomplete() {
		didTapToRegister()
	}
}
