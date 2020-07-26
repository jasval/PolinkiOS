//
//  AnswerButton.swift
//  Polink
//
//  Created by Jose Saldana on 06/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class AnswerButton: UIButton {
    
    var effect: Double? = 0
    
    //Setter function for effect
	func setEffect(_ effect: Double) {
        self.effect = effect
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    // Convenience initialiser
    convenience init(position: Int?) {
        self.init()
        layer.masksToBounds = true
        layer.cornerRadius = 5
        isEnabled = true
        isUserInteractionEnabled = true
        adjustsImageWhenHighlighted = true
        adjustsImageWhenDisabled = true
        autoresizesSubviews = true
        clearsContextBeforeDrawing = true
        alpha = 0
        switch position {
        case 1:
            setTitle(K.answerStrength.stronglyAgree, for: .normal)
			layer.shadowColor = UIColor.lightGray.cgColor
			layer.shadowRadius = 5
            setEffect(1.0)
            backgroundColor = #colorLiteral(red: 0, green: 0.4908769131, blue: 0, alpha: 1)
        case 2:
            setTitle(K.answerStrength.agree, for: .normal)
			layer.shadowColor = UIColor.lightGray.cgColor
			layer.shadowRadius = 5
            effect = 0.5
            backgroundColor = #colorLiteral(red: 0.366997391, green: 0.6819754839, blue: 0.1772149205, alpha: 1)

        case 3:
            setTitle(K.answerStrength.neutralUnsure, for: .normal)
			layer.shadowColor = UIColor.lightGray.cgColor
			layer.shadowRadius = 5
            effect = 0.0
            backgroundColor = #colorLiteral(red: 0.5296990871, green: 0.5297915936, blue: 0.5296869278, alpha: 1)

        case 4:
            setTitle(K.answerStrength.disagree, for: .normal)
			layer.shadowColor = UIColor.lightGray.cgColor
			layer.shadowRadius = 5
            effect = -0.5
            backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)

        case 5:
            setTitle(K.answerStrength.stronglyDisagree, for: .normal)
			layer.shadowColor = UIColor.lightGray.cgColor
			layer.shadowRadius = 5
            effect = -1.0
            backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)

        default:
            self.titleLabel?.text = "N/A"

        }
    }
}
