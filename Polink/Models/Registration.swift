//
//  Registration.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import FirebaseFirestore


// MARK: - Singleton for User Registration
// the use of a singleton will be revised in upcoming weeks once the project is finished


class Registration {
    var fname: String?
    var lname: String?
    var dob: Date?
    var gender: String?
    var location: GeoPoint?
    var geoLocCountry: String?
    var geoLocCity: String?
    
    static var state = Registration()
    
    var regCompletion: [Bool] = Array(repeating: false, count: 3)
    var polinkIdeology: [String : Double]?
    
    private init() { }
}
