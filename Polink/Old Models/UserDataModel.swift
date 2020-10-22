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
    
    enum Gender: Codable {

        case male
        case female
        case transgender
        case nonBinary
        case other
        
        enum Key: CodingKey {
            case rawValue
        }
        
        enum CodingError: Error {
            case unknownValue
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Key.self)
            let rawValue = try container.decode(String.self, forKey: .rawValue)
            switch rawValue {
            case "Male":
                self = .male
            case "Female":
                self = .female
            case "Transgender":
                self = .transgender
            case "Non-Binary":
                self = .nonBinary
            case "Other":
                self = .other
            default:
                throw CodingError.unknownValue
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Key.self)
            switch self {
            case .male:
                try container.encode("Male", forKey: .rawValue)
            case .female:
                try container.encode("Female", forKey: .rawValue)
            case .transgender:
                try container.encode("Transgender", forKey: .rawValue)
            case .nonBinary:
                try container.encode("Non-Binary", forKey: .rawValue)
            case .other:
                try container.encode("Other", forKey: .rawValue)
            default:
                throw CodingError.unknownValue
            }
        }
    }
    
    let uid: String
    var firstName: String?
    var lastName: String?
    var gender: Gender?
    var city: String?
    var country: String?
    let email: String
    var createdAt: Date?
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Add decoding strategy
        print(container)
    }
    
    init(_ uid: String, firstname: String, lastname: String, email: String, dob: Date, gender: Gender, ideology: [String : Double], location: GeoPoint, country: String, city: String) {
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
    
    init(_ uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
