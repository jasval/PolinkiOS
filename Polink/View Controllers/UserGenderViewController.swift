//
//  UserGenderViewController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit

class UserGenderViewController: UIViewController {
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var genderHero: UIImageView!
    @IBOutlet weak var femaleIcon: UIImageView!
    @IBOutlet weak var maleIcon: UIImageView!
    @IBOutlet weak var transIcon: UIImageView!
    @IBOutlet weak var otherIcon: UIImageView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var nextArrow: UIButton!
    
    var femaleImages: [UIImage] = []
    var maleImages: [UIImage] = []
    var transImages: [UIImage] = []
    var otherImages: [UIImage] = []

    var userpickedGender:Bool = false
    
    // Create an instance of our ModelController class
    var userRegistrationModel: Registration!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        checkMark.alpha = 0
        nextArrow.alpha = 0
        
        let tapGestureRecogniserFemale = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecogniser:)))
        let tapGestureRecogniserMale = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecogniser:)))
        let tapGestureRecogniserTrans = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecogniser:)))
        let tapGestureRecogniserOther = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecogniser:)))

        femaleIcon.tag = 0
        maleIcon.tag = 1
        transIcon.tag = 2
        otherIcon.tag = 3
        femaleIcon.isUserInteractionEnabled = true
        maleIcon.isUserInteractionEnabled = true
        transIcon.isUserInteractionEnabled = true
        otherIcon.isUserInteractionEnabled = true
        femaleIcon.addGestureRecognizer(tapGestureRecogniserFemale)
        maleIcon.addGestureRecognizer(tapGestureRecogniserMale)
        transIcon.addGestureRecognizer(tapGestureRecogniserTrans)
        otherIcon.addGestureRecognizer(tapGestureRecogniserOther)

    }
    

    // Populate image animations with the appropiately named files
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray: [UIImage] = []
        
        for imageCount in 0..<total {
            let imageName = "\(imagePrefix)-\(imageCount).png"
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        return imageArray
    }
    // Create animation with settings for UIImageViews
    func createAnimation(_ image: UIImageView) {
        image.animationDuration = 1
        image.animationRepeatCount = 1
    }
    
    @objc func imageTapped(tapGestureRecogniser: UITapGestureRecognizer) {
        let icon = tapGestureRecogniser.view as! UIImageView
        let x: String
        switch icon.tag {
        case 0:
            x = K.userGenders.female
            print(x)
        case 1:
            x = K.userGenders.male
            print(x)
        case 2:
            x = K.userGenders.trans
            print(x)
        case 3:
            x = K.userGenders.other
            print(x)
        default:
            x = K.userGenders.other
            print("Defaulted")
        }
        Registration.state.gender = x
        checkIfComplete()
    }
    
    func checkIfComplete() -> Void {
        if Registration.state.gender != nil {
            animateIn(checkMark, delay: 0.2)
            Registration.state.regCompletion[1] = true
            animateIn(nextArrow, delay: 0.8)
            print(Registration.state.dob?.description ?? "None")
            nextArrow.shake()
        } else {
            if checkMark.alpha > 0 {
                animateOut(checkMark)
                Registration.state.regCompletion[1] = false
            }
        }
    }
}
