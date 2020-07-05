//
//  LanguageModerationResources.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

class LanguageModerationResources {
	
	class func censoredWordsURL() -> URL? {
		return Bundle.main.url(forResource: "CensoredWordsList", withExtension: "json")
	}
	
}
