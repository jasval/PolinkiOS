//
//  ConfigurationObject.swift
//  Polink
//
//  Created by Josh Valdivia on 22/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import RealmSwift

class ConfigurationObject: Object {
	
	@objc dynamic var name: String = ""
	@objc dynamic var value: Bool = false
	
	override static func primaryKey() -> String? {
		return "name"
	}

	convenience init(name: String, value: Bool) {
		self.init()
		self.name = name
		self.value = value
	}
	
}
