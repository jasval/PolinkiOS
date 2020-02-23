//
//  UserDataModel.swift
//  polink.dev
//
//  Created by Jose Saldana on 13/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public struct UserDataModel: Codable {
    let uid: String
    var firstName: String?
    var lastName: String?
    var gender: String?
    var location: CGPoint?
    var email: String?
    let createdAt: Date?
    var values: [String : Double]?
    var dob: Date?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case firstName
        case lastName
        case gender
        case location
        case email
        case createdAt
        case values
        case dob
    }
    init(_ uid: String) {
        self.uid = uid
        createdAt = nil
        firstName = nil
        email = nil
        values = nil
        location = nil
        lastName = nil
        gender = nil
        dob = nil
    }
    
}
