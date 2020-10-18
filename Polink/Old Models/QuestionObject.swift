//
//  QuestionObject.swift
//  Polink
//
//  Created by Josh Valdivia on 16/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import RealmSwift

final class QuestionObject: Object {
	@objc dynamic var number: Int = 0
	@objc dynamic var prompt: String = ""
	@objc dynamic var effect: Effect? = Effect()
	override static func primaryKey() -> String? {
		return "number"
	}
}

final class Effect: Object {
	@objc dynamic var Economy: Double = 0.0
	@objc dynamic var Diplomacy: Double = 0.0
	@objc dynamic var Government: Double = 0.0
	@objc dynamic var Society: Double = 0.0
}
