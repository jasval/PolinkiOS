//
//  IdeologyMapping.swift
//  Polink
//
//  Created by Josh Valdivia on 19/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct IdeologyMapping: Codable {
	var econ: Double
	var dipl: Double
	var govt: Double
	var scty: Double
	
	enum CodingKeys: String, CodingKey {
		case econ = "Economy"
		case dipl = "Diplomacy"
		case govt = "Government"
		case scty = "Society"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.econ = try container.decode(Double.self, forKey: .econ)
		self.dipl = try container.decode(Double.self, forKey: .dipl)
		self.govt = try container.decode(Double.self, forKey: .govt)
		self.scty = try container.decode(Double.self, forKey: .scty)
	}
	
	init() {
		self.econ = 0
		self.dipl = 0
		self.scty = 0
		self.govt = 0
	}
	
	init(econ: Double, dipl: Double, scty: Double, govt: Double) {
		self.econ = econ
		self.govt = govt
		self.dipl = dipl
		self.scty = scty
	}
}
