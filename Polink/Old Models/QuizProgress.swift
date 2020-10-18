//
//  QuizProgress.swift
//  polink.dev
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class QuizProgress: UIProgressView {
    override func layoutSubviews() {
        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        layer.mask = maskLayer
    }
}
