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

struct Message: MessageType {
    
    let id: String?
    let content: String
    let sentDate: Date
    let sender: SenderType
    
    
//    let news: UIButton?

    var kind: MessageKind {
//        if let news = news {
//            return .custom(news)
//        } else {
            return .text(content)
//        }
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(user: User, content: String) {
        sender = Sender(senderId: user.uid, displayName: user.displayName ?? "None")
        self.content = content
        sentDate = Date()
        id = nil
    }
    
//    init(user: User, news: UIButton) {
//        sender = Sender(senderId: user.uid, displayName: user.displayName ?? "No name")
//        self.news = news
//        content = ""
//        sentDate = Date()
//        id = nil
//    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["sentDate"] as? Date else {
            return nil
        }
        guard let senderID = data["senderId"] as? String else {
            return nil
        }
        guard let senderUsername = data["senderUsername"] as? String else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate
        sender = Sender(senderId: senderID, displayName: senderUsername)
        
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString =  data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
}

extension Message: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "sentDate": sentDate,
            "senderID": sender.senderId,
            "senderUsername": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
}

extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
