//
//  ChatVC.swift
//  Polink
//
//  Created by Jose Saldana on 31/05/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import InputBarAccessoryView

final class ChatVC: MessagesViewController {
	
	
	private let db = Firestore.firestore()
	private var messagesReference: CollectionReference {
		return db.collection("rooms").document(room.id).collection("messages")
	}
	
	private let user: Sender
	private let room: Room
	
	init(user: Sender, room: Room) {
		self.user = user
		self.room = room
		super.init(nibName: nil, bundle: nil)
		
		let interlocutor = room.participantFeedbacks.first { (Participant) -> Bool in
			Participant.uid != user.senderId
		}
		
		title = interlocutor?.randomUsername
	}
	
	private var messages: [Message] = []
	private var messagesListener: ListenerRegistration?
	
	let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "H:mm  MMM dd"
		return formatter
	}()
	
	deinit {
		messagesListener?.remove()
		resignFirstResponder()
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if room.createdBy == user.senderId {
			if room.pending {
				let aPending = UIAlertController(title: nil, message: "\(title ?? "The user") still hasn't accepted your invitation", preferredStyle: .alert)
				aPending.addAction(UIAlertAction(title: "Return", style: .default, handler: { _ in
					// Pop current view controller and revert back to Lobby
					self.navigationController?.popViewController(animated: true)
				}))
				present(aPending, animated: true, completion: nil)
			} else {
				becomeFirstResponder()
				configureNavigationItem()
				configueMessageInputBar()
				addListeners()
				configureMessageCollectionView()
			}
		} else {
			if !(room.participantFeedbacks.contains{ (Participant) in
				Participant.uid == user.senderId
			}) {
				navigationController?.popViewController(animated: false)
			}
			if room.pending {
				let alert = UIAlertController(title: nil, message: "Do you agree to start a conversation with: \(title ?? "this new user")", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (UIAlertAction) in
					// Allow the conversation to start ...
					self.db.collection("rooms").document(self.room.id).updateData(["pending" : false])
					self.becomeFirstResponder()
					self.configureNavigationItem()
					self.configueMessageInputBar()
					self.addListeners()
					self.configureMessageCollectionView()
				}))
				alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (UIAlertAction) in
					// Dismiss the conversation ...
					self.navigationController?.popViewController(animated: true)
					self.db.collection("rooms").document(self.room.id).delete() { err in
						if let err = err {
							print("Error removing document: \(err)")
						} else {
							print("Document successfully removed!")
						}
					}
					
				}))
				present(alert, animated: true)
			}
		}
	}
	
	func configureNavigationItem() {
		navigationItem.largeTitleDisplayMode = .never
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.fill.badge.xmark"), style: .done, target: self, action: #selector(reportUser))
	}
	
	func configueMessageInputBar() {
		messageInputBar.sendButton.setTitle(nil, for: .normal)
		messageInputBar.sendButton.setTitle(nil, for: .selected)
		messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
		messageInputBar.sendButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
		messageInputBar.sendButton.setTitleColor( #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3), for: .highlighted)
		messageInputBar.sendButton.showsTouchWhenHighlighted = true
		messageInputBar.sendButton.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		messageInputBar.delegate = self
		
		let newsItem = InputBarButtonItem(type: .system)
		newsItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		newsItem.image = UIImage(systemName: "book.fill")
		newsItem.addTarget(self, action: #selector(newsButtonPressed), for: .primaryActionTriggered)
		newsItem.setSize(CGSize(60, 30), animated: false)
		
		messageInputBar.leftStackView.alignment = .center
		messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
		messageInputBar.setStackViewItems([newsItem], forStack: .left, animated: false)
	}
	
	func configureMessageCollectionView() {
		// Assign itself as the delegate for all things MessageKit
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		
		maintainPositionOnKeyboardFrameChanged = true
		scrollsToBottomOnKeyboardBeginsEditing = true
		
		
		if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
			layout.setMessageIncomingAvatarSize(.zero)
			layout.setMessageOutgoingAvatarSize(.zero)
			layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: .init(top: 5, left: 0, bottom: 0, right: 8)))
			layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: .init(top: 5, left: 8, bottom: 0, right: 0)))
		}
	}
	
	func addListeners() {
		messagesListener = messagesReference.addSnapshotListener(includeMetadataChanges: false, listener: { (QuerySnapshot, error) in
			guard let snapshot = QuerySnapshot else {
				print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
				return
			}
			
			snapshot.documentChanges.forEach { (change) in
				print("There are changes")
				self.handleDocumentChange(change)
			}
		})
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
	@objc private func reportUser() {
		let ac = UIAlertController(title: nil, message: "Are you sure you want to report this user?", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		ac.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { _ in
			// Remove room from Lobby and add to history with negative views
			
			// Pop current view controller and revert back to Lobby
			self.navigationController?.popViewController(animated: true)
		}))
		present(ac, animated: true, completion: nil)
		print("User reported!")
		return
	}
	
	@objc func newsButtonPressed() {
		
	}
	
	
	
	// MARK: - Helpers
	
	private func save(_ message: Message) {
		// reevaluate implementation if fails
		do {
			let result = try messagesReference.addDocument(from: message)
			print("Document reference: \(result.documentID )")
			
			self.messagesCollectionView.scrollToBottom()
		} catch {
			print("Error writing to database: \(error.localizedDescription)")
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
	
	private func modifyMessage(_ message: Message) {
		guard messages.contains(message) else {
			return
		}
		guard let index = messages.firstIndex(of: message) else {return}
		messages[index] = message
		
		messagesCollectionView.reloadData()
	}
	private func removeMessage(_ message: Message) {
		guard messages.contains(message) else {
			return
		}
		
		guard let index = messages.firstIndex(of: message) else {return}
		messages.remove(at: index)
		
		messagesCollectionView.reloadData()
	}
	
	private func handleDocumentChange(_ change: DocumentChange) {
		do {
			print(change.document.data())
			guard let message: Message = try change.document.data(as: Message.self) else {return}
			
			switch change.type {
			case .added:
				insertNewMessage(message)
			case .modified:
				modifyMessage(message)
			case .removed:
				removeMessage(message)
			default:
				break
			}
		} catch {
			print("There was an error decoding a message: \(error.localizedDescription)")
		}
	}
}

// MARK: - MessagesDisplayDelegate

extension ChatVC: MessagesDisplayDelegate {
	// 1. Change the background of each message depending if it is from the sender or the receiver
	func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		return isFromCurrentSender(message: message) ?  #colorLiteral(red: 0.5666330068, green: 1, blue: 0.5678768113, alpha: 1):#colorLiteral(red: 0.6398960133, green: 0.8511446251, blue: 1, alpha: 1)
	}
	
	// 2. To remove the header from each message we return false although it can be used to return a timestamp
	//	func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
	//		return false
	//	}
	
	// 3. Change the bubble style based on who sent the message
	func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
		let corner : MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
		return .bubbleTail(corner, .curved)
	}
	
	// 4. Messages text colour
	func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
		return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
	}
	
	func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
		avatarView.isHidden = true
	}
}

// MARK: - MessagesLayoutDelegate

extension ChatVC: MessagesLayoutDelegate {
	
	// 1. Hiding users avatar - there are none to display anyways
	//	func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
	//		return .zero
	//	}
	
	// 2. Adding padding between messages to improve legibility
	func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
		return CGSize(width: 0, height: 5)
	}
	
	// 3. Location message height defaults to zero
	func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		return 0
	}
	
}

// MARK: - MessagesDataSource

extension ChatVC: MessagesDataSource {
	
	// 1. A sender a simple structure created from the user values for user participant in room  passed by tableviewcontroller
	func currentSender() -> SenderType {
		// Use the authenticated user displayName or the default "Bob" Name
		return user
	}
	//
	
	// 2. The number of cells to be displayed in the MessagesCollectionView, the one below is the default implementation
	//	func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
	//		return 1
	//	}
	
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
	
	func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
		return 15
	}
	
	func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
		let dateString = formatter.string(from: message.sentDate)
		return NSAttributedString(string: dateString, attributes: [
			NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),
			NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.3)
		])
	}
}

// MARK: MessageInputBarDelegate

extension ChatVC: InputBarAccessoryViewDelegate {
	
	func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
		let attributedText = messageInputBar.inputTextView.attributedText!
		let range = NSRange(location: 0, length: attributedText.length)
		attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
			
			let substring = attributedText.attributedSubstring(from: range)
			let context = substring.attribute(.autocompleted, at: 0, effectiveRange: nil)
			print("Autocompleted: `", substring, "` with context", context ?? [])
		}
		
		let message = Message(sender: user, content: text)
		messageInputBar.inputTextView.text = String()
		//		messageInputBar.invalidatePlugins()
		
		
		// Send button activity animation
		
		messageInputBar.sendButton.startAnimating()
		messageInputBar.inputTextView.placeholder = "Sending..."
		DispatchQueue.global(qos: .default).async {
			// fake send request task to give the sensation to the user that there is some work going on
			sleep(1)
			DispatchQueue.main.async { [weak self] in
				self?.messageInputBar.sendButton.stopAnimating()
				self?.messageInputBar.inputTextView.placeholder = ""
				
				// Sends inserts the message in our local document, when Firestore notices the change it will update the database
				self?.save(message)
				self?.messagesCollectionView.scrollToBottom(animated: true)
			}
		}
	}
	
	func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
		if gesture.direction == .down {
			messageInputBar.inputTextViewDidEndEditing()
		}
	}
	
}

