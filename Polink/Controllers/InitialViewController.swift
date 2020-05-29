//
//  InitialViewController.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var mainTitleLabel: UILabel!
    
    // Creating an instance of the user defaults
    let defaults = UserDefaults.standard
    let testString = "This is a test string"

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
        self.defaults.set(self.testString, forKey: "Test")
        // Testing saving data in the user defaults
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        performSegue(withIdentifier: K.Segue.firstToRegister, sender: self)
    }
    @IBAction func signInPressed(_ sender: Any) {
        performSegue(withIdentifier: K.Segue.firstToLogin, sender: self)
    }
    

}
