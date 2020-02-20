//
//  RegisterViewController.swift
//  polink.dev
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import PopupDialog

class RegisterViewControllerCopy: UIViewController {
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet var fields: [UITextField]!
    

    var username: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the button corners to be rounded according to the buttons height.
        signupButton.layer.cornerRadius = signupButton.frame.height / 5
        for field in fields {
            field.layer.borderWidth = 1
            field.layer.masksToBounds = true
            field.layer.borderColor = UIColor.gray.cgColor
            field.layer.cornerRadius = field.frame.height / 5
        }
        
    }
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        if let name = nameField.text, let email = emailField.text, let password = passwordField.text {
            Auth.auth().createUser(withEmail: email, password: password) {authResult, error in
                // In case of an error present a popup to inform the user of the failed attempt to register
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
                    // Register name to user and Navigate to Homepage
                    self.createSpinnerView()
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (Timer) in
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        // Set user name as name entered in the Sign Up screen
                        changeRequest?.displayName = name
                        self.username = name

                        // Commit the changes
                        changeRequest?.commitChanges { (error) in
                            // Handling errors in setting the user name
                            print(error ?? "\(String(describing: Auth.auth().currentUser?.displayName))")
                        }
                        self.performSegue(withIdentifier: K.Segue.registrationToQuiz, sender: self)
                    }
                }
            }
        }
    }
    func createSpinnerView() {
        let child = SpinnerViewController()

        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ProfilerViewController
        destinationVC.username = nameField.text
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
