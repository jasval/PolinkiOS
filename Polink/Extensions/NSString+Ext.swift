//
//  NSString+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension NSString {
	func censored() -> NSString {
		return LanguageModeration.censorText(self as String) as NSString
	}
}
