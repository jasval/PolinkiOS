//
//  RegistrationViewController.swift
//  Polink
//
//  Created by Jasper Valdivia on 21/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    enum Kind {
        case basicInfo
        case gender
        case locationServices
        case verification
    }
    
    enum FieldKey {
        case firstName
        case lastName
        case dateOfBirth
        case gender
        case location
    }
    
    private let kind: Kind
    private var model: RegistrationUserViewModel?
    private var registrationHandler: ([FieldKey:Any]) -> (Bool)
    private lazy var registrationFields = [FieldKey:Any]()
    
    private lazy var titleText: UILabel = {
        var label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = Appearance.ColorPalette.primaryColor
        label.numberOfLines = 3
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        switch kind {
        case .basicInfo:
            label.text = LocalizedString("title_registration_basic")
        case .gender:
            label.text = LocalizedString("title_registration_gender")
        case .locationServices:
            label.text = LocalizedString("title_registration_location")
        case .verification:
            label.text = LocalizedString("title_registration_check")
        }
        return label
    }()
    
    private lazy var subtitleText: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = Appearance.ColorPalette.primaryTextColor
        label.numberOfLines = 3
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = true
        switch kind {
        case .basicInfo:
            label.text = LocalizedString("title_registration_basic_sub")
        default:
            break
        }
        return label
    }()
    
    private var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var checkMark: UIImageView  = {
        let view = UIImageView(image: UIImage(named: "checkmark.rectangle"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.adjustsImageSizeForAccessibilityContentSizeCategory = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressNext(_:))))
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    init(of kind: Kind, completionHandler: @escaping ([FieldKey:Any]) -> (Bool)) {
        self.kind = kind
        self.registrationHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        view.addSubview(contentView)
        view.addSubview(checkMark)
        let stackView = UIStackView(arrangedSubviews: [titleText, subtitleText])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.2),
            
            checkMark.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            checkMark.heightAnchor.constraint(equalToConstant: 50),
            checkMark.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            contentView.widthAnchor.constraint(equalTo: titleText.widthAnchor),
            contentView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: titleText.bottomAnchor, multiplier: 1),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: checkMark.topAnchor, constant: -50),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didPressNext(_ sender: UIImageView) {
        if let parentViewController = self.parent as? PageNavController {
            parentViewController.setViewControllers([parentViewController.viewControllerList[1]], direction: .forward, animated: true, completion: nil)
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

extension RegistrationViewController: UITextFieldDelegate {
    
    final private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    final private func deregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(_ sender: Notification) {
        guard let keyboardValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if sender.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
        } else {
            view.frame.origin.y = 0 - keyboardViewEndFrame.height
        }
    }
}
