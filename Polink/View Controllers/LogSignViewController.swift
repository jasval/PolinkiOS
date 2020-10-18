//
//  LogSignViewController.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class LogSignViewController: UIViewController {
    
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
        let button = Button(title: K.loginFlow.signUpEmail.rawValue, style: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var signInButton: Button = {
        let button = Button(title: K.loginFlow.signInEmail.rawValue, style: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        let buttonStack = UIStackView(arrangedSubviews: [signInButton, signUpButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 30
        
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            branding.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.frame.height / 5)),
            branding.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            branding.heightAnchor.constraint(equalToConstant: 150),
            branding.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
            buttonStack.widthAnchor.constraint(equalTo: branding.widthAnchor, multiplier: 0.7),
            buttonStack.topAnchor.constraint(equalToSystemSpacingBelow: branding.bottomAnchor, multiplier: 1),
            buttonStack.heightAnchor.constraint(equalToConstant: view.frame.height * 0.25),
            buttonStack.centerXAnchor.constraint(equalTo: branding.centerXAnchor)
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
}

// MARK: Navigation Extensions
extension LogSignViewController: RegisterDelegate, LoginDelegate {
    
    func didTapToRegister() {
        navigationController?.pushViewController(regVC, animated: true)
    }
    
    func userIsIncomplete() {
        didTapToRegister()
    }
    
}
