//
//  UserDefaults.swift
//  Polink
//
//  Created by Josh Valdivia on 16/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension UserDefaults {
	@objc dynamic var userIsListening: Bool {
		return bool(forKey: "USER_LISTENING")
	}
}
