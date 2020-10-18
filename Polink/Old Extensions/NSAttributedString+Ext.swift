//
//  NSAttributedString+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension NSAttributedString {
	
	func censored() -> NSAttributedString {
		
		let badWords = string.badWords()
		
		if badWords.isEmpty {
			return self
		}
		
		let cleanText = NSMutableAttributedString(attributedString: self)
		
		for word in badWords {
			
			let cleanWord = "".padding(toLength: word.count, withPad: "*", startingAt: 0)
			
			var range = (cleanText.string as NSString).range(of: word, options: .caseInsensitive)
			while range.location != NSNotFound {
				let attributes = cleanText.attributes(at: range.location, effectiveRange: nil)
				let cleanAttributedText = NSAttributedString(string: cleanWord, attributes: attributes)
				cleanText.replaceCharacters(in: range, with: cleanAttributedText)
				
				range = (cleanText.string as NSString).range(of: word, options: .caseInsensitive)
			}
		}
		
		return cleanText
	}
}
