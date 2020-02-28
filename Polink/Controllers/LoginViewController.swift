//
//  LoginViewController.swift
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


class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet var fields: [UITextField]!
    
    let db = Firestore.firestore()
    let name = Auth.auth().currentUser?.displayName

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
                            let dataDescription = document.data().map(String.init(describing:)) ?? nil
                            print("Document data: \(dataDescription ?? "null")")
                            self.performSegue(withIdentifier: K.Segue.loginToTab, sender: self)
                        } else {
                            print("User with uid: \(uid) has not completed his profile")
                            self.performSegue(withIdentifier: K.Segue.loginToRegistration, sender: self)
                        }
                    }
                }
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
