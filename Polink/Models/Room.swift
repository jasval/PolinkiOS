//
//  Room.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import CoreData

class Room: Codable {
	let id: String
	let createdAt: Date
	let createdBy: String
	var participantFeedbacks: [Participant]
	var pending: Bool
	private var reported: Bool
	var participants: [String]
	
	// Core Data Managed Object
//	@NSManaged var id: String
//	@NSManaged var createdAt: Date
//	@NSManaged var createdBy: String
//	@NSManaged var participantFeedbacks: [Participant]
//	@NSManaged var pending: Bool
//	@NSManaged var participants: [String]
	
	init(id: String, ownId: String, matchedId: String) {
		self.id = id
		self.createdAt = Date()
		self.createdBy = ownId
		self.pending = true
		let ownPersona = Participant(uid: ownId)
		let otherPersona = Participant(uid: matchedId)
		self.participantFeedbacks = [ownPersona, otherPersona]
		self.participants = [ownId,matchedId]
		self.reported = false
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		createdBy = try container.decode(String.self, forKey: .createdBy)
		var participanFeedbacktContainer = try container
			.nestedUnkeyedContainer(forKey: .participantFeedbacks)
		participantFeedbacks = Array<Participant>()
		while !participanFeedbacktContainer.isAtEnd {
			let participantFeedback: Participant = try participanFeedbacktContainer.decode(Participant.self)
			participantFeedbacks.append(participantFeedback)
		}
		pending = try container.decode(Bool.self, forKey: .pending)
		var participantContainer = try container
			.nestedUnkeyedContainer(forKey: .participants)
		participants = Array<String>()
		while !participantContainer.isAtEnd {
			let participant = try participantContainer.decode(String.self)
			participants.append(participant)
		}
		print("Previous timestamp decoding")
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		print("After timestamp decoding")
		reported = try container.decode(Bool.self, forKey: .reported)
	}
	
	func report() {
		reported = true
	}
	
}

extension Room: Comparable {
	
	static func == (lhs: Room, rhs: Room) -> Bool {
		return lhs.id == rhs.id
	}
	
	static func < (lhs: Room, rhs: Room) -> Bool {
		return lhs.createdAt < rhs.createdAt
	}
}
//struct Room {
//    let id: String?
//    let name: String
//    let country: String?
//    let createdAt: Date
//    let createdBy: String
//
//    // Review the creation of the room as the only way to create a new one will be through the matching algorithm.

//
//    init?(document: QueryDocumentSnapshot) {
//        let data = document.data()
//        let user = Auth.auth().currentUser
//
//        // The document needs to read the information contained in an array of participants
//        guard let participants = data["participants"] as? Array<Participant> else {
//            print("Couldn't return participants array as array of participants")
//            return nil
//        }
//        // Check the country written in the document in the database
//        guard let country = data["country"] as? String else {
//            return nil
//        }
//        // Look for the first index in the participants array that satisfies the predicate of the closure -- omitted the return boolean value as it can be inferred by the compiler
//        let interlocutor = participants.first { (Participant) in
//            Participant.uid != user?.uid
//        }
//
//        guard let createdAt = data["createdAt"] as? Date else {
//            return nil
//        }
//
//        // Indicates who initiated the conversation
//        self.createdBy = user?.uid ?? "noUserId"
//
//        // The date of the room is going to be the one found in the databse.
//        self.createdAt = createdAt
//        // The country of the room is going to be the country found in the document at firestore
//        self.country = country
//        // The id of the room is going to be the documentID in the database
//        self.id = document.documentID
//        // The name shown to the user will be the name of the interlocutor in that room, unless for some ungodly reason it is nill in which case it will default to "Anonymous"
//        self.name = interlocutor?.randomUsername ?? "Anonymous"
//    }
//
//}
//
//extension Room: DatabaseRepresentation {
//
//    var representation: [String : Any] {
//        var rep = ["name" : name]
//
//        if let id = id {
//            rep["id"] = id
//        }
//
//        return rep
//    }
//}
