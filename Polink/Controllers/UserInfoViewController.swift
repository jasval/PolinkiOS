//
//  UserInfoViewController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var fieldStack: UIStackView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextArrow: UIButton!
    
    var userPickedDate:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        registerKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deRegisterKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        titleText.alpha = 0
        fieldStack.alpha = 0
        checkMark.alpha = 0
        nextArrow.alpha = 0
        configureDateBoundaries()
        animateIn(titleText, delay: 1)
        animateIn(fieldStack, delay: 2)
        
        
    }
    //MARK: Keyboard notification observer methods
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    func deRegisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height + 15 - view.safeAreaInsets.bottom, right: 0)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    
    
    // A checker that visually calls the checkmark if all necessary fields have been completed
    func checkIfComplete(){
        //Checks if fname and lname are not null
        if let fname = firstNameTextField.text, let lname = lastNameTextField.text {
            if userPickedDate {
                if isValidName(fname) && isValidName(lname) {
                    UserDS.user.writeFLD(fname, lastname: lname, dateOfBirth: datePicker.date)
                    print("Wrote to file!")
                    animateIn(checkMark, delay: 0.2)
                    UserDS.user.completePage(index: 0)
//                    let storyBoard:UIStoryboard = UIStoryboard(name: "Registration", bundle: nil)
//                    let userGenderViewController = storyBoard.instantiateViewController(identifier: "UserGenderViewController") as! UserGenderViewController
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        self.present(userGenderViewController, animated: true, completion: nil)
                    self.animateIn(nextArrow, delay: 0.8)
                    self.nextArrow.shake()
                } else {
                    if checkMark.alpha > 0 {
                        animateOut(checkMark)
                        UserDS.user.incompletePage(index: 0)
                    }
                }
            } 
        } else {
            if checkMark.alpha > 0 {
                animateOut(checkMark)
                UserDS.user.incompletePage(index: 0)
            }
            return
        }
    }
    
    // Configure Maximum and minimum dates
    func configureDateBoundaries() {
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = -18
        components.month = 12
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -150
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        if userPickedDate == false {
            userPickedDate = true
        }
        checkIfComplete()
        return
    }
    // Validate First and Lastname user input to be at least length 2 each
    func isValidName(_ name: String) -> Bool {
        let stringRegex = "^.{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", stringRegex).evaluate(with: name)
    }

    
    // What happens when the user presses return on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
            return false
        } else {
            textField.endEditing(true)
            return true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkIfComplete()
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
