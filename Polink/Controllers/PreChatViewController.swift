//
//  PreChatViewController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class PreChatViewController: UIViewController {
    @IBOutlet weak var checkPageOne: UIImageView!
    @IBOutlet weak var checkPageTwo: UIImageView!
    @IBOutlet weak var checkPageThree: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nextButtonIcon: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkPageOne.alpha = 0
        checkPageTwo.alpha = 0
        checkPageThree.alpha = 0
//        nextButtonIcon.alpha = 0
        progressBar.alpha = 0
        
        let nextButtonGestureRecogniser = UITapGestureRecognizer.init(target: self, action: #selector(nextPressed(_:)))
        nextButtonIcon.addGestureRecognizer(nextButtonGestureRecogniser)
    }
    override func viewDidAppear(_ animated: Bool) {
        updateUI()
    }
    
    @objc func nextPressed(_ sender: Any) {
        if reduceBools(Registration.state.regCompletion) == true {
            self.performSegue(withIdentifier: K.Segue.registrationToQuiz, sender: self)
            print("View will transition now")
        } else {
            reportIncompleteRegistration()
            print("Set up has not been completed")
        }
    }
    
    func reduceBools (_ values: [Bool]) -> Bool {
        return !values.contains(false)
    }
    
    func reportIncompleteRegistration() {
        // Create alert and action to present to the user in case location services is disabled
        let alert = UIAlertController(title: "Your registration is not complete", message: "Please swipe back and complete any remaining screens", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        // Add action to the alert.
        alert.addAction(okAction)
        
        // Present the alert to the user
        present(alert, animated: true, completion: nil)
        
    }
    func updateUI() {
        if Registration.state.regCompletion[0] {
            if checkPageOne.alpha == 0 {
                animateIn(checkPageOne, delay: 0.2)
                animateIn(progressBar, delay: 0.5)
            }
        }
        if Registration.state.regCompletion[1] {
            if checkPageTwo.alpha == 0 {
                animateIn(checkPageTwo, delay: 0.2)
            }
        }
        if Registration.state.regCompletion[2] {
            if checkPageThree.alpha == 0 {
                animateIn(checkPageThree, delay: 0.2)
                animateIn(nextButtonIcon, delay: 0.5)
            }
        }
        for i in Registration.state.regCompletion {
            if i {
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    let newProgress = self.progressBar.progress + 0.35
                    self.progressBar.setProgress(newProgress, animated: true)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                    let newProgress = self.progressBar.progress - 0.35
                    self.progressBar.setProgress(newProgress, animated: true)
                }, completion: nil)
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
