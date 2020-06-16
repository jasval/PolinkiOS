//
//  UserDataModel.swift
//  Polink
//
//  Created by Jose Saldana on 13/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import FirebaseFirestore

public struct UserDataModel: Codable {
    let uid: String
    var firstName: String?
    var lastName: String?
    var gender: String?
    var city: String?
    var country: String?
    var email: String?
    let createdAt: Date?
    var ideology: [String : Double]?
    var dob: Date?
    var chats: [String]?
    var history: [String]?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case firstName
        case lastName
        case gender
        case city
        case country
        case email
        case createdAt
        case ideology
        case dob
        case chats
        case history
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
        self.country = country
        self.city = city
        self.chats = []
        self.history = []
    }
    
}
