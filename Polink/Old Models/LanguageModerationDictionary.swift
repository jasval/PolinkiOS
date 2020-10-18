//
//  LanguageModerationDictionary.swift
//  Polink
//
//  Created by Josh Valdivia on 29/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct LanguageModerationDictionary {
	
	static let censoredWords: Set<String> = {
		
		guard let fileURL = LanguageModerationResources.censoredWordsURL() else {
			print("url was wrong")
			return Set<String>()
			
		}
		
		print(fileURL)
		
		do {
			let fileData = try Data(contentsOf: fileURL, options: NSData.ReadingOptions.uncached)
			
			guard let words = try JSONSerialization.jsonObject(with: fileData, options: []) as? [String] else {
				return Set<String>()
			}
			print(words)
			return Set(words)
			
		} catch {
			
			return Set<String>()
			
		}
		
	}()
	
}
