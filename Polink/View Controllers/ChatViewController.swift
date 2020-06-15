//
//  ChatViewController.swift
//  Polink
//
//  Created by Jose Saldana on 31/05/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import Photos
import MessageKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import InputBarAccessoryView

final class ChatViewController: MessagesViewController {
    
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    
    private let user: User
    private let room: Room
    
    init(user: User, room: Room) {
        self.user = user
        self.room = room
        super.init(nibName: nil, bundle: nil)
        
        title = room.name
    }
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    
    deinit {
        messageListener?.remove()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = room.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        // Connecting to the database that holds the messages
        reference = db.collection(["rooms", id, "thread"].joined(separator: "/"))
        
        
        messageListener = reference?.addSnapshotListener { (querySnapshot , error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { (change) in
                self.handleDocumentChange(change)
            }
        }
        
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .white // this might have to be changed in the future
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.delegate = self
        
        
        // Add new message type to the list of admitted messages --> I need to deregister the other message types if possible
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomNewsCell.self)
        
        
        // Assign itself as the delegate for all things MessageKit
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        
        
    }
    
    // for the implementation of the custom message type
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        // Dequeueing a custom cell type
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomNewsCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    
    
    
    // MARK: - Actions
    
    // Action to report user (NEEDS TO BE COMPLETED)
    //  @objc private func reportUser() {
    //      let ac = UIAlertController(title: nil, message: "Are you sure you want to report this user?", preferredStyle: .alert)
    //      ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    //      ac.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { _ in
    //          // Action to report in a do try catch structure to take a screenshot of the offence or select offending messages and send them for revision, then flag the user and sign out of the conversation.
    //      }))
    //      present(ac, animated: true, completion: nil)
    //      print("User reported!")
    //      return
    //  }
    
    
    
    // MARK: - Helpers
    
    // Save message using the model specified in DatabaseRepresentation and the reference defined and the beginning of this document.
    private func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message \(e.localizedDescription)")
                return
            }
            
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.lastIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            // we won't implement any image sending for now but this is the place where you would check for any type of content that is not text, for example a news message (custom)
            insertNewMessage(message)
        default:
            break
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    // 1. Change the background of each message depending if it is from the sender or the receiver
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?  #colorLiteral(red: 0.5666330068, green: 1, blue: 0.5678768113, alpha: 1):#colorLiteral(red: 0.6398960133, green: 0.8511446251, blue: 1, alpha: 1)
    }
    
    // 2. To remove the header from each message we return false although it can be used to return a timestamp
    //    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
    //
    //    }
    
    // 3. Change the bubble style based on who sent the message
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // 4. Messages text colour
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    // 1. A sender a simple structure created from the authenticated user id and name
    func currentSender() -> SenderType {
        // Use the authenticated user displayName or the default "Bob" Name
        return Sender(senderId: user.uid, displayName: user.displayName ?? "Bob")
    }
    //
    
    // 2. The number of cells to be displayed in the MessagesCollectionView, the one below is the default implementation
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    // 3. Number of sections to be displayed in the MessagesCollectionView
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        
        // format the sender display name to lower its profile and avoid distracting the reader
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let date = Date()
        let formate = date.getFormattedDate(format: "EEEE, MMM d")
        
        return NSAttributedString(
            string: formate,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
}

// MARK: MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompleted, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context", context ?? [])
        }
        
        let message = Message(user: user, content: text)
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        
        // Send button activity animation
        
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending ..."
        DispatchQueue.global(qos: .default).async {
            // fale send request task to give the sensation to the user that there is some work going on
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = ""
                self?.insertNewMessage(message)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

}
