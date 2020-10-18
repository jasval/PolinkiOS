//
//  String+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension String {
	
	func badWords() -> Set<String> {
		
		var delimiterSet = CharacterSet()
		delimiterSet.formUnion(CharacterSet.punctuationCharacters)
		delimiterSet.formUnion(CharacterSet.whitespacesAndNewlines)
		
		// Set the words to be separated by the delimiter set defined above
		let words = Set(self.lowercased().components(separatedBy: delimiterSet))
		
		// Identify the matches between the set of words from the string and the local Set of bad words.
		return words.intersection(LanguageModerationDictionary.censoredWords)
	}
	
	func containsBadWords() -> Bool {
		// if the result from the badWords function is empty return false
		return !badWords().isEmpty
	}
	
	func censored() -> String {
		return LanguageModeration.censorText(self)
	}
	
	mutating func censor() {
		self = censored()
	}
}
