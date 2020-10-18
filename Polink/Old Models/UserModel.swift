//
//  UserModel.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct UserModel {
    private let uid: String!
    private let createdAt: Date!
    private var email: String!
    private var firstName: String!
    private var lastName: String?
    private var dateOfBirth: Date!
    private var gender: UserGender!
    private var city: String?
    private var country: String?
    private var ideology: [String : Double]?
    private var chats: [String]?
    private var history: [String]?
    
    enum UserGender: String {
        case male = "Male"
        case female = "Female"
        case transgender = "Transgender"
        case nonBinary = "Non-Binary"
        case other = "Other"
    }

    private enum CodingKeys: String, CodingKey {
        case uid
        case createdAt
        case email
        case firstName
        case lastName
        case dateOfBirth
        case gender
        case city
        case country
        case ideology
        case chats
        case history
    }
    
    init(firstName: String, lastName: String? = nil, gender: UserGender, dateOfBirth: Date, email: String) {
        self.uid = UUID().uuidString
        self.createdAt = Date()
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.email = email
    }

}
