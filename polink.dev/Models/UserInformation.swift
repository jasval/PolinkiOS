//
//  UserInformation.swift
//  polink.dev
//
//  Created by Jose Saldana on 22/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct UserInformation {
    var uid: String?
    var fname: String?
    var lname: String?
    var dob: Date?
    var gender: String?
    var location: GeoPoint?
    var geoLocCountry: String?
    var geoLocCity: String?
    
    mutating func writeFLD(_ firstname: String, lastname: String, dateOfBirth: Date){
        fname = firstname
        lname = lastname
        dob = dateOfBirth
        print("Primary information has been recorded")
    }
    mutating func writeGender(_ gender: String){
        self.gender = gender
        print("Gender has been recorded")
    }
    mutating func writegeoLoc(_ geoLocCountry: String, geoLocCity: String){
        self.geoLocCountry = geoLocCountry
        self.geoLocCity = geoLocCity
        print("Geolocation has been recorded")
    }
    mutating func writeLocation(_ location: GeoPoint){
        self.location = location
        print("Latitude and Longitude were recorded")
    }
    
    //There exists the posibility to use this singleton to temporarily
    // store the data to be written in Firestore
    static let userInfo = UserInformation()
}
