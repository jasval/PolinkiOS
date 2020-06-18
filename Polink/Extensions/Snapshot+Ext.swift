//
//  Snapshot+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 15/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Extension to make the query document snapshot be able to decode the data coming in
extension QueryDocumentSnapshot {
    
    func decoded<Type: Decodable>() throws -> Type {
        
        // Decode the snapshot into any generic decodable object
        let jsonData = try JSONSerialization.data(withJSONObject: data(), options: [])
        let object = try JSONDecoder().decode(Type.self, from: jsonData)
        // Return the decoded object
        return object
    }
}

extension QuerySnapshot {
    
    // Returns an array of our generic type as we will be dealing with a larger volume of queries
    func decoded<Type: Decodable>() throws -> [Type] {
        // We use the map function for each of the objects in the array to decode them with the QueryDocumentSnapshot extension defined above -> we asign the values to an array of object that is returned to the user
        let objects: [Type] = try documents.map({ try $0.decoded() })
        return objects
    }
}
