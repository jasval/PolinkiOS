//
//  ProfilePrivate.swift
//  Polink
//
//  Created by Josh Valdivia on 15/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct ProfilePrivate {
    var email: String
    var firstName: String
    var lastName: String
    var gender: String
	let createdAt: Date
    let dateOfBirth: Date
    var history: [Room] = []
    
}

extension ProfilePrivate: Codable {
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		email = try container.decode(String.self, forKey: .email)
		firstName = try container.decode(String.self, forKey: .firstName)
		lastName = try container.decode(String.self, forKey: .lastName)
		gender = try container.decode(String.self, forKey: .gender)
		dateOfBirth = try container.decode(Date.self, forKey: .dateOfBirth)
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		history = Array<Room>()
		var historyContainer = try container
			.nestedUnkeyedContainer(forKey: .history)
		while !historyContainer.isAtEnd {
			let room = try historyContainer.decode(Room.self)
			history.append(room)
		}
	}
}
