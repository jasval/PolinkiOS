//
//  ChatVC.swift
//  Polink
//
//  Created by Jose Saldana on 31/05/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseFunctions
import FirebaseFirestore
import FirebaseFirestoreSwift
import InputBarAccessoryView
import SafariServices

final class ChatVC: MessagesViewController {
	fileprivate lazy var functions = Functions.functions()
	
	private let db = Firestore.firestore()
	
	private var messagesReference: CollectionReference {
		return db.collection("rooms").document(room.id).collection("messages")
	}
	
	private var documentReference: DocumentReference {
		return db.collection("rooms").document(room.id)
	}
	
	private let user: Sender
	private var room: Room
	
	init(user: Sender, room: Room, delegate: LobbyViewControllerDelegate) {
		self.user = user
		self.room = room
		self.lobbyDelegate = delegate
		super.init(nibName: nil, bundle: nil)
		
		let interlocutor = room.participantFeedbacks.first { (Participant) -> Bool in
			Participant.uid != user.senderId
		}
		
		title = interlocutor?.randomUsername
	}
	
	private var messages : [Message] = []
	private var messagesListener: ListenerRegistration?
	private var roomListener: ListenerRegistration?
	private var lobbyDelegate: LobbyViewControllerDelegate
	
	private var presentationAnimationController: PopupPresentationAnimationController?
	
	let formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "H:mm  MMM dd"
		return formatter
	}()
	
	deinit {
		messagesListener?.remove()
		roomListener?.remove()
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
					self.lobbyDelegate.reloadData()
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
				alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { [unowned self](UIAlertAction) in
					// Allow the conversation to start ...
					self.db.collection("rooms").document(self.room.id).updateData(["pending" : false])
					self.becomeFirstResponder()
					self.configureNavigationItem()
					self.configueMessageInputBar()
					self.addListeners()
					self.configureMessageCollectionView()
					self.presentPromptPicker()
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
		
		let agreementItem = InputBarButtonItem(type: .system)
		agreementItem.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		agreementItem.image = UIImage(systemName: "shield.lefthalf.fill")
		agreementItem.addTarget(self, action: #selector(agreementButtonPressed), for: .primaryActionTriggered)
		agreementItem.setSize(CGSize(60, 30), animated: false)
		
		messageInputBar.leftStackView.alignment = .center
		messageInputBar.setLeftStackViewWidthConstant(to: 100, animated: false)
		messageInputBar.setStackViewItems([agreementItem, newsItem], forStack: .left, animated: false)
	}
	
	func configureMessageCollectionView() {
		// Assign itself as the delegate for all things MessageKit
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messagesCollectionView.messageCellDelegate = self
		
		maintainPositionOnKeyboardFrameChanged = true
		scrollsToBottomOnKeyboardBeginsEditing = true
		
		messagesCollectionView.isUserInteractionEnabled = true
		
		
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
		roomListener = documentReference.addSnapshotListener {[unowned self] documentSnapshot, error in
			guard let document = documentSnapshot else {
				print("Error fetching document: \(error!)")
				return
			}
//			let source = document.metadata.hasPendingWrites ? "Local" : "Server"
//			print("\(source) data: \(document.data() ?? [:])")
			do {
				let downloadedRoom = try document.data(as: Room.self)
				if downloadedRoom != nil {
					self.room = downloadedRoom!
				}
			} catch {
				fatalError("Data from room couldn't be saved to current room")
			}
//			self.room.newsDiscussed = document.get("newsDiscussed") as! [String]
//			self.room.participantFeedbacks = document.get("participantFeedbacks") as! [ParticipantFeedback]
		}
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
	
	// Action to report user
	@objc private func reportUser() {
		let ac = UIAlertController(title: nil, message: "Are you sure you want to report this user?", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		ac.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { [unowned self] _ in
			
			//report current room
			self.room.report()
			
			// Write current room and messages to a new location in the database
			let batch = self.db.batch()
			do {
				try batch.setData(from: self.room, forDocument: self.db.collection("history").document(self.room.id))
				for message in self.messages {
					try batch.setData(from: message, forDocument: self.db.collection("history").document(self.room.id).collection("messages").document(message.messageId))
				}
			} catch {
				print("There was an error sending the data \(error.localizedDescription)")
				return
			}
			
			batch.commit() { err in
				if let err = err {
					print("There was an error commiting the batch write: \(err.localizedDescription)")
					return
				} else {
					print("Batch write succeded")
					
					// Call the callable function to delete the subcollection and the document
					let path = self.db.collection("rooms").document(self.room.id).path
					print(path)
					self.deleteAtPath(pathToDelete: path)
					// Pop current view controller and revert back to Lobby
					self.navigationController?.popViewController(animated: true)
				}
			}
			// Remove room from Lobby and add to history with negative views
			
			
		}))
		present(ac, animated: true, completion: nil)
		print("User reported!")
		return
	}
	
	// News button to present the collection of views for the day
	@objc func newsButtonPressed() {
		if room.newsDiscussed.count > 5 {
			let alert = UIAlertController(title: "You have reached the limit.", message: "Too many news are being discussed in this room.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		}
		presentPromptPicker()
	}
	
	@objc func agreementButtonPressed() {
		let vc = FeedbackVC()
		vc.modalPresentationStyle = .popover
//		vc.isModalInPresentation = true
		self.present(vc, animated: true, completion: nil)
	}
	
	@objc func openSafariView(_ input: String?) {
		guard let url = URL(string: input!) else {
			print("didnt work")
			return
			
		}
		let config = SFSafariViewController.Configuration()
		config.entersReaderIfAvailable = true
		print("did work")
		let vc = SFSafariViewController(url: url, configuration: config)
		vc.modalPresentationStyle = .popover
		present(vc, animated: true)
	}
	
	
	func presentPromptPicker(isInitialPrompt: Bool = false) {
		print("Receiving news from delegate...")
		let newsViewController = lobbyDelegate.retrieveNewsInformation(delegate: self, isInitial: isInitialPrompt)
		newsViewController.transitioningDelegate = self
		newsViewController.modalPresentationStyle = .custom
		newsViewController.layoutEmphasis = .text
		print(newsViewController.contentView)
		self.present(newsViewController, animated: true)
	}
	
	func deleteAtPath(pathToDelete: String) {
		let jsonObject : [String: Any] = ["path" : pathToDelete]
		if JSONSerialization.isValidJSONObject(jsonObject) {
			print(true)
		} else {
			print(false)
		}
		
		print(jsonObject.description as Any)
		
		let deleteFunction = functions.httpsCallable("recursiveDelete")
		deleteFunction.call(jsonObject) { (result, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			if let result = result {
				print(String(describing: result.data))
				print("Completed!")
			}
			
		}
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
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		//		let message = messages[indexPath.section]
		//		if URL(string: message.content ?? "") != nil && message.content?.contains("http") == true {
		//			let contentAtt = NSMutableAttributedString(string: message.content ?? "")
		//			contentAtt.addAttribute(.link, value: message.content ?? "", range: NSRange(location: 0, length: contentAtt.length))
		//			openSafariView(message.content)
		//		} else {
		//		}
		let message = messages[indexPath.section]
		openSafariView(message.content)
	}
	
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
		// Censor the users input
		var cleanText = text
		cleanText.censor()
		
		print(cleanText)
		let message = Message(sender: user, content: cleanText)
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
extension ChatVC: MessageCellDelegate {
	func didTapMessage(in cell: MessageCollectionViewCell) {
		guard let index = messagesCollectionView.indexPath(for: cell) else {return}
		//		_ = messageForItem(at: index, in: messagesCollectionView)
		openSafariView(messages[index.section].content)
	}
}

extension ChatVC: NewsViewControllerDelegate {
	
	func newsWasSelected(_ newsToSend: News) {
		let message = Message(sender: user, content: newsToSend.articleURL)
		self.save(message)
		
		//Set Timer for inactivity of the button
		
		
		//Add newsDiscussed to current Room
		documentReference.updateData(["newsDiscussed" : FieldValue.arrayUnion([newsToSend.title])]) { Error in
			guard let error = Error else {return}
			print(error.localizedDescription)
		}
	}
	
	func newsViewControllerDidFinish(_ newsViewController: NewsViewController) {
		newsViewController.dismiss(animated: true, completion: nil)
	}
	
}

extension ChatVC: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = PopupPresentationAnimationController()
		self.presentationAnimationController = animationController
		return animationController
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let overlayView = presentationAnimationController?.overlayView
		presentationAnimationController = nil
		return PopupDismissalAnimationController(overlayView: overlayView)
	}
}
