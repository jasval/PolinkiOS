//
//  NSMutableString+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension NSMutableString {
	
	func censor() {
		setString(LanguageModeration.censorText(self as String))
	}
	
}
