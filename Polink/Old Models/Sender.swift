//
//  Sender.swift
//  Polink
//
//  Created by Josh Valdivia on 14/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    
    var senderId: String
    
    var displayName: String
    
    init(senderId: String, displayName: String?) {
        self.senderId = senderId
        self.displayName = displayName ?? "Anonymous"
    }
    
}
