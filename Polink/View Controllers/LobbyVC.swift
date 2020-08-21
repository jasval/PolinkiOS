//
//  LobbyVC.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData

protocol LobbyViewControllerDelegate {
	func retrieveNewsInformation(delegate: NewsViewControllerDelegate, isInitial: Bool) -> NewsViewController?
	func reloadData()
}

class LobbyVC: UITableViewController {
	
	private let roomCellIdentifier = "roomCell"
	private var currentRoomAlertController: UIAlertController?
	
	private let db = Firestore.firestore()
	
	private var roomReference: CollectionReference {
		return db.collection("rooms")
	}
	private var privateProfileReference: DocumentReference {
		return db.collection("users").document(currentUser.uid).collection("private").document("userData")
	}
	
	private var rooms = [Room]()
	private var history = [Room]()
	
	
	// Store the news here.
	private var availableNews = [News]()
	private var newsReference: CollectionReference {
		return db.collection("news")
	}
	private var newsListener: ListenerRegistration?
	//
	private var roomListener: ListenerRegistration?
	private var privateProfileListener: ListenerRegistration?
	
	private let currentUser: User
	
	deinit {
		roomListener?.remove()
		privateProfileListener?.remove()
	}
	
	init(user: User) {
		self.currentUser = user
		super.init(style: .grouped)
		
		title = "Rooms"
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clearsSelectionOnViewWillAppear = true
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: roomCellIdentifier)
		
		
		roomListener = roomReference.whereField("participants", arrayContains: currentUser.uid).whereField("reported", isEqualTo: false)
			.addSnapshotListener(includeMetadataChanges: false, listener: { [weak self] (QuerySnapshot, error) in
			guard let snapshot = QuerySnapshot else {
				print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
				return
			}
			
			snapshot.documentChanges.forEach { (change) in
				print("There are changes")
				self?.handleDocumentChange(change)
			}
		})
		
		privateProfileListener = privateProfileReference.addSnapshotListener({ [weak self] (DocumentSnapshot, error) in
			guard let snapshot = DocumentSnapshot else {
				print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
				return
			}
			do {
				let privateProfile = try snapshot.data(as: ProfilePrivate.self)
				guard let storedHistory = privateProfile?.history else {return}
				print("Synchronising database history with local history")
				self?.history = storedHistory
			} catch {
				print("error: \(error.localizedDescription)")
			}
		})
		
		// Listen for news changes in news and call function to get latest ones ==> REGISTRATION
		// Create custom date for retrieval of news.
		newsListener = newsReference.addSnapshotListener(includeMetadataChanges: false, listener: { [weak self] (querySnapshot, error) in
			guard querySnapshot != nil else {
				print("Error listening for news updates: \(error?.localizedDescription ?? "No error")")
				return
			}
			do {
				print("Getting latest news...")
				try self?.getLatestNews()
			} catch {
				print("An error ocurred parsing the news from the server, specifically \(error.localizedDescription)")
				return
			}
		})
		
		for room in rooms {
			print(room.participantFeedbacks[0].uid)
		}
	}
	
	func getLatestNews() throws {
		let todayStr = Date().getFormattedDate(format: "yyy-MM-dd")
		print(todayStr)
		db.collection("news").document(todayStr).getDocument { [weak self](documentSnapshot, error) in
			guard let document = documentSnapshot else {return}
			if document.exists {
				self?.db.collection("news").document(todayStr).collection("articles").getDocuments { (querySnapshot, error) in
					guard let query = querySnapshot else {return}
					if query.documents.count > 0 {
						do {
							print("Updating Available news from today...")
							self?.availableNews = try query.decoded()
						} catch {
							print("An error ocurred parsing the news from \(todayStr)")
							print(error.localizedDescription)
							return
						}
					}
				}
			} else {
				var dayComponent = DateComponents()
				dayComponent.day = -1
				let calendarComponent = Calendar.current
				let yesterdayStr = calendarComponent.date(byAdding: dayComponent, to: Date())?.getFormattedDate(format: "yyy-MM-dd")
				
				self?.db.collection("news").document(yesterdayStr!).collection("articles").getDocuments(completion: { (querySnapshot, error) in
					guard let query = querySnapshot else {return}
					
					do {
						print("Updating Available news from yesterday...")
						self?.availableNews = try query.decoded()
					} catch {
						print("An error ocurred parsing the news from \(yesterdayStr!)  specifically \(error.localizedDescription)")
						return
					}
				})
			}
		}
		for news in availableNews {
			print(news.title + "  " + String(describing: news.publishedAt))
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		//		navigationController?.isToolbarHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		//		navigationController?.isToolbarHidden = true
	}
	
	// MARK: - Actions
	
	
	// MARK: - Helpers
	
	// Needs to be revised in order to implement
	private func createRoom(id: String, ownId: String, matchedId: String) {
	print("Creating room")
		
		let room = Room(id: id, ownId: ownId, matchedId: matchedId)
		
		do {
			try roomReference.document(id).setData(from: room)
			print("New room with reference: \(id) was created succesfully")
		} catch {
			print("There was an error creating the new room: \(error.localizedDescription)")
			return
		}
		
	}
	
	// Adding a new chatroom to table
	private func addRoomToTable(_ room: Room) {
		guard !rooms.contains(room) else {
			return
		}
		
		rooms.append(room)
		rooms.sort()
		
		guard let index = rooms.firstIndex(of: room) else {
			return
		}
		tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
	}
	
	// Modifying an existing chatroom to our table
	private func updateRoomInTable(_ room: Room) {
		guard let index = rooms.firstIndex(of: room) else {
			return
		}
		
		rooms[index] = room
		tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
	}
	
	// Removing a room from our table
	private func removeRoomFromTable(_ room: Room) {
		guard let index = rooms.firstIndex(of: room) else {
			return
		}
		
		rooms.remove(at: index)
		tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
	}
	
	// handling any change to our rooms in order to update the UI
	private func handleDocumentChange(_ change: DocumentChange) {
		do {
			guard let room: Room = try change.document.data(as: Room.self) else {return}
			
			switch change.type {
				
			case .added:
				print("We add")
				addRoomToTable(room)
				
			case .modified:
				print("We modify")
				updateRoomInTable(room)
				
			case .removed:
				print("We remove")
				removeRoomFromTable(room)
			}
		} catch {
			print("There was a problem handling the document change and decoding into room object: \(error.localizedDescription)")
		}
	}
}
// MARK: - TableViewDelegate

extension LobbyVC {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rooms.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: roomCellIdentifier, for: indexPath)
		
		cell.accessoryType = .disclosureIndicator
		
		// Name to be shown in the table is the randomised name of the other participant
		let interlocutor: ParticipantFeedback? = rooms[indexPath.row].participantFeedbacks.first { (Participant) -> Bool in
			Participant.uid != currentUser.uid
		}
		
		cell.textLabel?.text = interlocutor?.randomUsername
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let room = rooms[indexPath.row]
		
		// Create a sender from participants data
		let rootSender = room.participantFeedbacks.first { (Participant) -> Bool in
			Participant.uid == currentUser.uid
		}
		for room in rooms {
			print(room.participantFeedbacks[0].uid)
		}

		let sender = Sender(senderId: currentUser.uid, displayName: rootSender?.randomUsername)
		// Push view controller passing the user and the room in question
		let vc = ChatVC(user: sender, room: room, delegate: self)
		navigationController?.pushViewController(vc, animated: true)
	}
}

// MARK: - Matching Delegate

extension LobbyVC: HomeVCDelegate {
	func getHistory(completion: @escaping () -> ()) {
		db.collection("history").whereField("participants", arrayContains: self.currentUser.uid).getDocuments { [weak self] (querySnapshot, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let documents = querySnapshot?.documents else {return}
			self?.history = []
			do {
				for item in documents {
					let room: Room = try item.data(as: Room.self)!
					self?.history.append(room)
				}
				completion()
			} catch {
				print(error.localizedDescription)
				return
			}
		}
	}
	
	func matchingDataIsPassed(userProfiles: [(String, Double)]) {
		print("Matching began")
		getHistory {
			for profile in userProfiles {
				var roomExistsAlready: Bool = false
				print(profile)
				if profile.0 > self.currentUser.uid {
					let roomId = profile.0 + self.currentUser.uid
					print("Matched profile is bigger, then: \(roomId)")
					for room in self.rooms {
						if room.id != roomId {
							print("Room is not the same")
						} else {
							print("A room already exist between these two users")
							roomExistsAlready = true
						}
					}
					for room in self.history {
						if room.id != roomId {
							print("Room is not the same in history")
						} else {
							print("A room already exist between these two users in history")
							roomExistsAlready = true
						}
					}
					if roomExistsAlready {
						continue
					} else {
						self.createRoom(id: roomId, ownId: self.currentUser.uid, matchedId: profile.0)
						return
					}
				} else {
					let roomId = self.currentUser.uid + profile.0
					print("Matched profile is smaller, then: \(roomId)")
					for room in self.rooms {
						if room.id != roomId {
							print("Room is not the same")
						} else {
							print("A room already exist between these two users")
							roomExistsAlready = true
						}
					}
					for room in self.history {
						if room.id != roomId {
							print("Room is not the same in history")
						} else {
							print("A room already exist between these two users in history")
							roomExistsAlready = true
						}
					}
					if roomExistsAlready {
						continue
					} else {
						self.createRoom(id: roomId, ownId: self.currentUser.uid, matchedId: profile.0)
						return
					}
				}
			}

		}
	}
}

extension LobbyVC: LobbyViewControllerDelegate {
	
	func retrieveNewsInformation(delegate: NewsViewControllerDelegate, isInitial: Bool) -> NewsViewController? {
		
		if availableNews.count != 0 {
			let newsViewController = NewsViewController(newsToDisplay: availableNews, delegate: delegate)
			
			return newsViewController
		} else {
			return nil
		}
	}
	
	func reloadData() {
		tableView.reloadData()
	}
	
}
