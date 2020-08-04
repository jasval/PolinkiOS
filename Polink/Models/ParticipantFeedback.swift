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

struct ParticipantFeedback: Codable {
	let uid: String
	var agreement: Bool
	var conversationRating: Double
	var engagementRating: Double
	var informativeRating: Double
	var randomUsername: String
	var interlocutorIdeas: String
	var agreedOn: String
	var learnings: String
	var finalRebuttal: String
	var perceivedIdeology: IdeologyMapping
	
	
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
		case perceivedIdeology
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
		self.perceivedIdeology = IdeologyMapping()
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.uid = try container.decode(String.self, forKey: .uid)
		self.agreement = try container.decode(Bool.self, forKey: .agreement)
		self.conversationRating = try container.decode(Double.self, forKey: .conversationRating)
		self.engagementRating = try container.decode(Double.self, forKey: .engagementRating)
		self.informativeRating = try container.decode(Double.self, forKey: .informativeRating)
		self.interlocutorIdeas = try container.decode(String.self, forKey: .interlocutorIdeas)
		self.agreedOn = try container.decode(String.self, forKey: .agreedOn)
		self.learnings = try container.decode(String.self, forKey: .learnings)
		self.finalRebuttal = try container.decode(String.self, forKey: .finalRebuttal)
		self.randomUsername = try container.decode(String.self, forKey: .randomUsername)
		self.perceivedIdeology = try container.decode(IdeologyMapping.self, forKey: .perceivedIdeology)
		
	}
}
