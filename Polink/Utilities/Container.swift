//
//  Container.swift
//  Polink
//
//  Created by Josh Valdivia on 16/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import RealmSwift

public final class Container {
	private let realm: Realm
	
	public convenience init(userID: String?) throws {
		guard let userID = userID else {
			try self.init(realm: Realm())
			return
		}
		
		var config = Realm.Configuration()
		// Use the default directory, but replace the filename with the username
		config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(userID).realm")

		// Set this as the configuration used for the default Realm
		Realm.Configuration.defaultConfiguration = config
		
		try self.init(realm: Realm())
	}
	
	internal init(realm: Realm) {
		self.realm = realm
	}
	
	public func write(_ block: (WriteTransaction) throws -> Void ) throws {
		let transaction = WriteTransaction(realm: realm)
		try realm.write {
			try block(transaction)
		}
	}


}
