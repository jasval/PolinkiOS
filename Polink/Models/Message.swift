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
    
    let id: String?
    let content: String?
    let sentDate: Date
    let sender: SenderType
    var downloadURL: URL?

    
//    let news: UIButton?

    var kind: MessageKind {
//        if let news = news {
//            return .custom(news)
//        } else {
        return .text(content ?? "")
//        }
    }
    
    // If there is an assigned id already return that id, otherwise generate own id
    var messageId: String {
        return id ?? UUID().uuidString
    }


    init(sender: Sender, content: String) {
        // Do something (I still need to figure out what to do exactly ... )
        self.sender = sender
        self.content = content
        self.sentDate = Date()
        
        // do not assign an id manually as it will be assigned by Firestore by document when reloading the data
        id = nil
    }
    
//    init(user: User, news: UIButton) {
//        sender = Sender(senderId: user.uid, displayName: user.displayName ?? "No name")
//        self.news = news
//        content = ""
//        sentDate = Date()
//        id = nil
//    }
    
//    init?(document: QueryDocumentSnapshot) {
//        let data = document.data()
//
//        guard let sentDate = data["sentDate"] as? Date else {
//            return nil
//        }
//        guard let senderID = data["senderId"] as? String else {
//            return nil
//        }
//        guard let senderUsername = data["senderUsername"] as? String else {
//            return nil
//        }
//
//        id = document.documentID
//
//        self.sentDate = sentDate
//        sender = Sender(senderId: senderID, displayName: senderUsername)
//
//
//        if let content = data["content"] as? String {
//            self.content = content
//            downloadURL = nil
//        } else if let urlString =  data["url"] as? String, let url = URL(string: urlString) {
//            downloadURL = url
//            content = ""
//        } else {
//            return nil
//        }
//    }
}

extension Message: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case messageId
        case senderId
        case senderUsername
        case sentDate
        case content
        case downloadURL
        case kind
    }
    
    init(from decoder: Decoder) throws {
        //learn how to use it
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.content = try container.decode(String.self, forKey: .content)
        
        let username = try container.decode(String.self, forKey: .senderUsername)
        let senderId = try container.decode(String.self, forKey: .senderId)
        
        self.sender = Sender(senderId: senderId, displayName: username)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.downloadURL = try container.decode(URL.self, forKey: .downloadURL)
        self.sentDate = try container.decode(Date.self, forKey: .sentDate)
        
        // MessageKind is only get so its populating automatically
        
    }

    func encode(to encoder: Encoder) throws {
        // Learn how to use it
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(sender.senderId, forKey: .senderId)
        try container.encode(sender.displayName, forKey: .senderUsername)
        
        if content != nil {
            try container.encode("text", forKey: .kind)
        } else {
            try container.encode("news", forKey: .kind)
        }
        try container.encode(content, forKey: .content)
        try container.encode(downloadURL, forKey: .downloadURL)
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

//extension Message: DatabaseRepresentation {
//    var representation: [String : Any] {
//        var rep: [String : Any] = [
//            "sentDate": sentDate,
//            "senderID": sender.senderId,
//            "senderUsername": sender.displayName
//        ]
//
//        if let url = downloadURL {
//            rep["url"] = url.absoluteString
//        } else {
//            rep["content"] = content
//        }
//
//        return rep
//    }
//}
//

