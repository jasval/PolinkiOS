//
//  ChatViewController.swift
//  Polink
//
//  Created by Jose Saldana on 31/05/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        // Do any additional setup after loading the view.
    }
    


}

// MARK: - Messages Collection View Methods

// reevaluate and move appropiately sample structure
public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}
let sender = Sender(senderId: "unique_id", displayName: "Bob")
let messages : [MessageType] = []

extension ChatViewController: MessagesDataSource {

    // Conforming to MessagesDataSource
    func currentSender() -> SenderType {
        // Sender has been deprecated and in turn changed for SenderType
        return Sender(senderId: "unique_id", displayName: "Bob")
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

