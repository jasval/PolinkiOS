//
//  NSLayoutContraint+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 19/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {
	func activate(withIdentifier id: String) {
		(self.identifier, self.isActive) = (id, true)
	}
}
