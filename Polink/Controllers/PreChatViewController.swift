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
        
    }
    
    @objc func nextPressed(_ sender: Any) {
        let checks = UserDS.user.regCompletion.values
        var boolArray : [Bool] = []
        for value in checks {
            boolArray.append(value)
        }
        if reduceBools(boolArray) == true {
            self.performSegue(withIdentifier: K.Segue.registrationToQuiz, sender: self)
            print("View will transition now")
        } else {
            print("Set up has not been completed")
        }
    }
    func reduceBools (_ values: [Bool]) -> Bool {
        return !values.contains(false)
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
