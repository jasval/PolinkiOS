//
//  News.swift
//  Polink
//
//  Created by Josh Valdivia on 06/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class News : Codable {
	var title: String
	var description: String?
	var imageURL: String?
	var articleURL: String
	var publishedAt: String
	var source: String?
	var author: String?
	
	enum CodingKeys: String, CodingKey {
		case title
		case description
		case articleURL = "url"
		case imageURL = "image_url"
		case publishedAt
		case source
		case author
	}
	
	required init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		// For some decodings it is permitted to return a nil value --> try?
		self.title = try container.decode(String.self, forKey: .title)
		self.description = try? container.decode(String.self, forKey: .description)
		self.imageURL = try? container.decode(String.self, forKey: .imageURL)
		self.articleURL = try container.decode(String.self, forKey: .articleURL)
		self.publishedAt = try container.decode(String.self, forKey: .publishedAt)
		self.author = try? container.decode(String.self, forKey: .author)
		self.source = try? container.decode(String.self, forKey: .source)
	}

	
}

