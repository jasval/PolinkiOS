//
//  CoreDataStack.swift
//  Polink
//
//  Created by Josh Valdivia on 01/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	// To use the core data stack import CoreData in the VC of your choice and initialise a lazy variable calling the stack by its modelName -> You need to create a model of the same name first.
	
	private let modelName: String
	
	// This is the only entry point required to access the rest of the CoreData Stack.
	lazy var managedContext: NSManagedObjectContext = {
		return self.storeContainer.viewContext
	}()
	
	init(modelName: String) {
		self.modelName = modelName
	}
	
	private lazy var storeContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: self.modelName)
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error as NSError? {
				print("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	// Convenience method to save the stack's managed object context and handle any resulting errors.
	func saveContext () {
		// Only save if the manage object has any changes.
		guard managedContext.hasChanges else { return }
		
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Unresolved error \(error), \(error.userInfo)")
		}
	}
}

