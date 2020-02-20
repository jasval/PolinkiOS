//
//  AnswerButton.swift
//  polink.dev
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
            setEffect(1.0)
            backgroundColor = UIColor.green
        case 2:
            setTitle(K.answerStrength.agree, for: .normal)
            effect = 0.5
            backgroundColor = UIColor.blue

        case 3:
            setTitle(K.answerStrength.neutralUnsure, for: .normal)
            effect = 0.0
            backgroundColor = UIColor.lightGray

        case 4:
            setTitle(K.answerStrength.disagree, for: .normal)
            effect = -0.5
            backgroundColor = UIColor.orange

        case 5:
            setTitle(K.answerStrength.stronglyDisagree, for: .normal)
            effect = -1.0
            backgroundColor = UIColor.red

        default:
            self.titleLabel?.text = "N/A"

        }
    }
}
