//
//  RealmUtil.swift
//  Polink
//
//  Created by Josh Valdivia on 17/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUtil {
	static func setDefaultRealmForUser(username: String) {
		var config = Realm.Configuration()
		
		// Use the default directory, but replace the filename with the username
		config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
		
		// Set this as the configuration used for the default Realm
		Realm.Configuration.defaultConfiguration = config
	}
}
