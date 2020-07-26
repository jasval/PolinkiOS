//
//  SignInVC.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import PopupDialog
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol LoginDelegate {
	func userIsIncomplete()
}

class SignInVC: UIViewController {
	
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet var fields: [UITextField]!
	
	var loginScreenDelegate: LoginDelegate?
	
	let db = Firestore.firestore()
	let name = Auth.auth().currentUser?.displayName

	// Special constructor considering the view is still in Storyboard
	static func makeloginVC(delegate: LoginDelegate) -> SignInVC {
		let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginViewController") as! SignInVC
		
		newViewController.loginScreenDelegate = delegate
		return newViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		signInButton.layer.masksToBounds = true
		signInButton.layer.cornerRadius = signInButton.frame.height / 5
		for field in fields {
			field.layer.borderWidth = 1
			field.layer.masksToBounds = true
			field.layer.borderColor = UIColor.gray.cgColor
			field.layer.cornerRadius = field.frame.height / 5
		}
	}
	
	@IBAction func signInPressed(_ sender: Any) {
		let button = sender as? UIButton
		button?.pulsate()
		if let email = emailField.text, let password = passwordField.text {
			Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
				if let e = error {
					let popup = PopupDialog(title: K.Popup.signUpError, message: "\(e.localizedDescription)", buttonAlignment: .vertical, transitionStyle: .fadeIn, tapGestureDismissal: true, panGestureDismissal: true, hideStatusBar: false, completion: nil)
					
					_ = popup.viewController as! PopupDialogDefaultViewController
					
					// Format the popup
					let dialogAppearance = PopupDialogDefaultView.appearance()
					dialogAppearance.titleFont = .boldSystemFont(ofSize: 14)
					let overlayAppearance = PopupDialogOverlayView.appearance()
					overlayAppearance.color = .init(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
					overlayAppearance.blurEnabled = true
					overlayAppearance.blurRadius = 25
					overlayAppearance.opacity = 0.3
					
					// Present the formatted popup
					self.present(popup, animated: true, completion: nil)
					
				} else {
					
					let uid:String = Auth.auth().currentUser!.uid
					let usersRef = self.db.collection("users").document(uid)
					
					usersRef.getDocument { (document, error) in
						if let document = document, document.exists {
							// Debug description of Firestore document
							print(document.description)
							
							// For testing purposes
							UserDefaults.standard.set(true, forKey: "LOGGED_IN")
							
							let vc = TabBarController()
							let keywindow = UIApplication.shared.windows.first {$0.isKeyWindow}
							keywindow?.rootViewController = vc
							
						} else {
							print("User with uid: \(uid) has not completed his profile")
							self.loginScreenDelegate?.userIsIncomplete()
							self.dismiss(animated: true)
						}
					}
				}
			}
		}
	}
}
