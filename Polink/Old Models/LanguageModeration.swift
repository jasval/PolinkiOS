//
//  LanguageModeration.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct LanguageModeration {
	static func censorText(_ string: String) -> String {
		var cleanText = string
		
		for word in string.badWords() {
			
			let cleanWord = "".padding(toLength: word.count, withPad: "*", startingAt: 0)
			
			cleanText = cleanText.replacingOccurrences(of: word, with: cleanWord, options: [.caseInsensitive], range: nil)
			
		}
		
		return cleanText
	}
}
