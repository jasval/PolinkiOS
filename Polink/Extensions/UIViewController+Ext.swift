//
//  UIVC+Ext.swift
//  Polink
//
//  Created by Jose Saldana on 05/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // Animate function for UIView visibility specifying object and delay
    func animateIn(_ item: UIView, delay: Double) {
        UIView.animate(withDuration: 1, delay: delay, options: .curveEaseInOut, animations: {
            item.alpha = 1
        }, completion: nil)
    }
    func animateOut(_ item: UIView) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            item.alpha = 0
        }, completion: nil)
    }
}
