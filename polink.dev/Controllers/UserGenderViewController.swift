//
//  UserGenderViewController.swift
//  polink.dev
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
    
    var userInfo = UserInformation()
    
    
    var femaleImages: [UIImage] = []
    var maleImages: [UIImage] = []
    var transImages: [UIImage] = []
    var otherImages: [UIImage] = []

    var userpickedGender:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        checkMark.alpha = 0
        
        
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
//        femaleImages = createImageArray(total: 20, imagePrefix: "female")
//        femaleIcon.animationImages = femaleImages
//        createAnimation(femaleIcon)
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
        switch icon.tag {
        case 0:
            userInfo.writeGender(K.userGenders.female)
            print(K.userGenders.female)
        case 1:
            userInfo.writeGender(K.userGenders.male)
            print(K.userGenders.male)
        case 2:
            userInfo.writeGender(K.userGenders.trans)
            print(K.userGenders.trans)
        case 3:
            userInfo.writeGender(K.userGenders.other)
            print(K.userGenders.other)
        default:
            userInfo.writeGender(K.userGenders.other)
            print("Defaulted")
        }
        checkIfComplete()
    }
    func checkIfComplete() -> Void {
        if userInfo.gender != nil {
            animateIn(checkMark, delay: 0.5)
        } else {
            return
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
