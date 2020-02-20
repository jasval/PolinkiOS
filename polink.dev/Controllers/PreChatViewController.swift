//
//  PreChatViewController.swift
//  polink.dev
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class PreChatViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.performSegue(withIdentifier: K.Segue.registrationToQuiz, sender: self)
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
