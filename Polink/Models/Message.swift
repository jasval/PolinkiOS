//
//  Message.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.w
//

import Firebase
import MessageKit
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: MessageType {
	
	let content: String?
	let sentDate: Date
	let sender: SenderType
//	var downloadURL: String?
	// generate own id
	let messageId: String
	
	//    let news: UIButton?
	
	var kind: MessageKind {
			return .text(content ?? "")
	}
	
	
	init(sender: Sender, content: String) {
		// Do something (I still need to figure out what to do exactly ... )
		self.sender = sender
		self.content = content
		self.sentDate = Date()
		self.messageId = UUID().uuidString
	}
	
	//    init(user: User, news: UIButton) {
	//        sender = Sender(senderId: user.uid, displayName: user.displayName ?? "No name")
	//        self.news = news
	//        content = ""
	//        sentDate = Date()
	//        id = nil
	//    }
}

extension Message: Codable {
	
	enum CodingKeys: String, CodingKey {
		case messageId
		case senderId
		case senderUsername
		case sentDate
		case content
//		case downloadURL
		case kind
	}
	
	init(from decoder: Decoder) throws {
		//learn how to use it
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.content = try container.decode(String.self, forKey: .content)
		
		let username = try container.decode(String.self, forKey: .senderUsername)
		let senderId = try container.decode(String.self, forKey: .senderId)
		
		self.sender = Sender(senderId: senderId, displayName: username)
		
		self.messageId = try container.decode(String.self, forKey: .messageId)
//		self.downloadURL = try container.decode(String.self, forKey: .downloadURL)
		self.sentDate = try container.decode(Date.self, forKey: .sentDate)
		
		// MessageKind is only get so its populating automatically
		
	}
	
	func encode(to encoder: Encoder) throws {
		// Learn how to use it
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(messageId, forKey: .messageId)
		try container.encode(sender.senderId, forKey: .senderId)
		try container.encode(sender.displayName, forKey: .senderUsername)
		
		if content != nil {
			try container.encode("text", forKey: .kind)
		} else {
			try container.encode("news", forKey: .kind)
		}
		try container.encode(content, forKey: .content)
//		try container.encode(downloadURL, forKey: .downloadURL)
		try container.encode(sentDate, forKey: .sentDate)
	}
}

extension Message: Comparable {
	static func == (lhs: Message, rhs: Message) -> Bool {
		return lhs.messageId == rhs.messageId
	}
	
	static func < (lhs: Message, rhs: Message) -> Bool {
		return lhs.sentDate < rhs.sentDate
	}
}


