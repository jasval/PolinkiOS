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
    var firstName: String
    var lastName: String?
    var gender: String?
    var location: Location?
    var email: String
    let createdAt: Date
    var values: [String : Double]?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case firstName
        case lastName
        case gender
        case location
        case email
        case createdAt
        case values
    }
    init(_ uid: String, fname: String, email: String, values: [String : Double]) {
        self.uid = uid
        self.createdAt = Date.init()
        firstName = fname
        self.email = email
        self.values = values
        location = nil
        lastName = nil
        gender = nil
    }
    
}
