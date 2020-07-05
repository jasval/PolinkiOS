//
//  Room+CoreDataProperties.swift
//  
//
//  Created by Josh Valdivia on 02/07/2020.
//
//

import Foundation
import CoreData


extension Room {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    @NSManaged public var id: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var createdBy: String?
    @NSManaged public var participantFeedbacks: [NSObject]?
    @NSManaged public var pending: Bool
    @NSManaged public var participants: [String]?

}
