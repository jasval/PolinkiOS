//
//  UserDataModel.swift
//  Polink
//
//  Created by Jose Saldana on 13/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import FirebaseFirestore

public struct UserDataModel: Codable {
    let uid: String
    var firstName: String?
    var lastName: String?
    var gender: String?
    var location: GeoPoint?
    var city: String?
    var country: String?
    var email: String?
    let createdAt: Date?
    var ideology: [String : Double]?
    var dob: Date?
    var chats: [String]?
    var history: [String]?
    var pendingChats: [String]?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case firstName
        case lastName
        case gender
        case location
        case city
        case country
        case email
        case createdAt
        case ideology
        case dob
        case chats
        case history
        case pendingChats
    }
    
    init(_ uid: String, firstname: String, lastname: String, email: String, dob: Date, gender: String, ideology: [String : Double], location: GeoPoint, country: String, city: String) {
        self.uid = uid
        createdAt = Date.init()
        self.firstName = firstname
        self.lastName = lastname
        self.email = email
        self.dob = dob
        self.gender = gender
        self.ideology = ideology
        self.location = location
        self.country = country
        self.city = city
        self.chats = []
        self.history = []
    }
    
}
