//
//  ProfilePrivate.swift
//  Polink
//
//  Created by Josh Valdivia on 15/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct ProfilePrivate: Codable {
    var email: String
    var firstName: String
    var lastName: String
    var gender: String
    let createdAt: Date = Date()
    let dateOfBirth: Date
    var history: [Room] = []
    
}
