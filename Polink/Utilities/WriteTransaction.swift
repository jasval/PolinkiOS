//
//  WriteTransaction.swift
//  Polink
//
//  Created by Josh Valdivia on 16/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import RealmSwift

public final class WriteTransaction {
	private let realm: Realm
	internal init(realm: Realm) {
		self.realm = realm
	}
	
	public func add<T: Persistable>( _ value: T, update: Realm.UpdatePolicy) {
		realm.add(value.managedObject(), update: update)
	}
}
