//
//  Persistable.swift
//  Polink
//
//  Created by Josh Valdivia on 16/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Persistable {
	associatedtype ManagedObject: RealmSwift.Object
	init (managedObject: ManagedObject)
	func managedObject() -> ManagedObject
}
