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
        
        // Assign itself as the delegate for all things MessageKit
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
//        messageInputBar.delegate = self

    }
    


}

// reevaluate and move appropiately sample structure
public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}
let sender = Sender(senderId: "unique_id", displayName: "Bob")
let messages : [MessageType] = []

// MARK: - MessagesDataSource
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
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    // 1. Hiding users avatar - there are none to display anyways
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    // 2. Adding padding between messages to improve legibility
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    // 3. Location message height defaults to zero
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}
    
// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    // 1. Change the background of each message depending if it is from the sender or the receiver
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1): #colorLiteral(red: 0.2274509804, green: 0.2274509804, blue: 0.2352941176, alpha: 1)
    }
    // 2. Change the bubble style based on who sent the message
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

