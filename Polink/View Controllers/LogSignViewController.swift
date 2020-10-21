//
//  LogSignViewController.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

class LogSignViewController: UIViewController {
    
    fileprivate var db = Firestore.firestore()
    fileprivate var currentNonce: String?
    private let branding = AnimatedLogo()
    
    private lazy var regVC: UIViewController = {
        let sb = UIStoryboard(name: "Registration", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "RegistrationController")
        return vc
    }()
    private lazy var quizVC: UIViewController = {
        let sb = UIStoryboard(name: "Quiz", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "QuizVC")
        return vc
    }()
    private lazy var signInVC: SignInVC = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "loginViewController") as! SignInVC
        return vc
    }()
    private lazy var signUpVC: SignUpVC = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "registerViewController") as! SignUpVC
        return vc
    }()
    
    
    private var signUpButton: Button = {
        let button = Button(title: LocalizedString("settings_email_signUp"), style: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var signInButton: Button = {
        let button = Button(title: LocalizedString("settings_email_signIn"), style: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var signInWithAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        button.addTarget(self, action: #selector(handleLogInWithAppleId(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.setupHandlers()
        }
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        branding.playAnimation()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(branding)
        
        let buttonStack = UIStackView(arrangedSubviews: [signInButton, signUpButton, signInWithAppleButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.alignment = .fill
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 30
        
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            branding.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height / 5)),
            branding.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            branding.heightAnchor.constraint(equalToConstant: 150),
            branding.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            buttonStack.widthAnchor.constraint(equalTo: branding.widthAnchor, multiplier: 0.8),
            buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: branding.bottomAnchor, multiplier: 1),
            buttonStack.centerXAnchor.constraint(equalTo: branding.centerXAnchor),
            
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.heightAnchor.constraint(equalTo: signInButton.heightAnchor),
            signInWithAppleButton.heightAnchor.constraint(equalTo: signInButton.heightAnchor)
        ])
    }
    
    func setupHandlers() {
        signUpButton.tapHandler = { [unowned self] in
            present(signUpVC, animated: true)
        }
        signInButton.tapHandler = { [unowned self] in
            present(signInVC, animated: true)
        }
    }
    
    @objc func handleLogInWithAppleId(_ sender: ASAuthorizationAppleIDButton) {
        let nonce = Security.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Security.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

// MARK: - Authorization Delegate
extension LogSignViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, not no login request was sent.")
            }
            guard let appleIdToken = appleIdCredential.identityToken else {
                print("unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIdToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error as NSError? {
                    /*
                     Error. If error.code == .MissingOrInvalidNonce, make sure you are
                     sending the SHA256-hashed nonce as a hex string with your request to Apple.
                     */
                    print("what happened!?")
                    print(error.code)
                    print(error.userInfo)
                    print(error.localizedDescription)
                    return
                }
                
                let uid = Auth.auth().currentUser!.uid
                let usersRef = self.db.collection("users").document(uid)
                
                usersRef.getDocument { [weak self] (document, error) in
                    if let document = document, document.exists {
                        // Debug description of Firestore document
                        print(document.description)
                                                
                        let vc = TabBarController()
                        let keywindow = UIApplication.shared.windows.first {$0.isKeyWindow}
                        keywindow?.rootViewController = vc
                        
                    } else {
                        print("User with uid: \(uid) has not completed his profile")
                        self?.userIsIncomplete()
                        self?.dismiss(animated: true)
                    }
                }

            }
        }
    }
}

// MARK: - Navigation Extensions
extension LogSignViewController: RegisterDelegate, LoginDelegate {
    
    func didTapToRegister() {
        navigationController?.pushViewController(regVC, animated: true)
    }
    
    func userIsIncomplete() {
        didTapToRegister()
    }
    
}
