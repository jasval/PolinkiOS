//
//  Room.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import FirebaseFirestore


struct Room {
    let id: String?
    let name: String
    
    init(name: String) {
        id = nil
        self.name = name
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        id = document.documentID
        self.name = name
    }
    
}

extension Room: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep = ["name" : name]
        
        if let id = id {
            rep["id"] = id
        }
        
        return rep
    }
}

extension Room: Comparable {
    
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Room, rhs: Room) -> Bool {
        return lhs.name < rhs.name
    }
}
