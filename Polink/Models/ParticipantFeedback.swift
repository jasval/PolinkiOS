//
//  ParticipantFeedback.swift
//  Polink
//
//  Created by Josh Valdivia on 14/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Fakery
import CoreData

class ParticipantFeedback: Codable {
	let uid: String
	var agreement: Bool
	var conversationRating: Int
	var engagementRating: Int
	var informativeRating: Int
	var randomUsername: String
	var interlocutorIdeas: String
	var agreedOn: String
	var learnings: String
	var finalRebuttal: String
	
	
	//	@NSManaged var uid: String
	//	@NSManaged var agreement: Bool
	//	@NSManaged var conversationRating: Int
	//	@NSManaged var engagementRating: Int
	//	@NSManaged var informativeRating: Int
	//	@NSManaged var randomUsername: String
	
	
	enum CodingKeys: String, CodingKey {
		case uid
		case agreement
		case conversationRating
		case engagementRating
		case informativeRating
		case randomUsername
		case interlocutorIdeas
		case agreedOn
		case learnings
		case finalRebuttal
	}
	
	init(uid: String) {
		self.uid = uid
		self.agreement = false
		self.conversationRating = 0
		self.engagementRating = 0
		self.informativeRating = 0
		self.interlocutorIdeas = ""
		self.agreedOn = ""
		self.learnings = ""
		self.finalRebuttal = ""
		// use a random generator for names to provide a random anonymised username.
		let faker = Faker()
		self.randomUsername = faker.internet.username()
	}
	
}
