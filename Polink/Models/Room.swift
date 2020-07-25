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

struct Room: Codable {
	let id: String
	let createdAt: Date
	let createdBy: String
	var participantFeedbacks: [ParticipantFeedback]
	var pending: Bool
	private var reported: Bool
	var participants: [String]
	var newsDiscussed: [String]
	var finished: Bool
		
	init(id: String, ownId: String, matchedId: String) {
		self.id = id
		self.createdAt = Date()
		self.createdBy = ownId
		self.pending = true
		let ownPersona = ParticipantFeedback(uid: ownId)
		let otherPersona = ParticipantFeedback(uid: matchedId)
		self.participantFeedbacks = [ownPersona, otherPersona]
		self.participants = [ownId,matchedId]
		self.reported = false
		self.newsDiscussed = Array<String>()
		self.finished = false
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		createdBy = try container.decode(String.self, forKey: .createdBy)
		print(id)
		var participanFeedbacktContainer = try container
			.nestedUnkeyedContainer(forKey: .participantFeedbacks)
		participantFeedbacks = Array<ParticipantFeedback>()
		while !participanFeedbacktContainer.isAtEnd {
			let participantFeedback: ParticipantFeedback = try participanFeedbacktContainer.decode(ParticipantFeedback.self)
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
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		reported = try container.decode(Bool.self, forKey: .reported)
		var newsContainer = try container.nestedUnkeyedContainer(forKey: .newsDiscussed)
		newsDiscussed = Array<String>()
		while !newsContainer.isAtEnd {
			let newsTitle = try newsContainer.decode(String.self)
			newsDiscussed.append(newsTitle)
		}
		finished = try container.decode(Bool.self, forKey: .finished)
	}
	
	mutating func report() {
		reported = true
	}
	
	mutating func finish() {
		finished = true
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
