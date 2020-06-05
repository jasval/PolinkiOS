//
//  UserDS.swift
//  Polink
//
//  Created by Jose Saldana on 22/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserDS {
    
    var location: GeoPoint?
    var geoLocCountry: String?
    var geoLocCity: String?

    
    
    // Singleton to store all information
    static let user = UserDS()
    
//    MARK: Setters


    func writegeoLoc(_ geoLocCountry: String, geoLocCity: String){
        self.geoLocCountry = geoLocCountry
        self.geoLocCity = geoLocCity
        print("Geolocation has been recorded")
    }
    func writeLocation(_ location: GeoPoint){
        self.location = location
        print("Latitude and Longitude were recorded")
    }


}
