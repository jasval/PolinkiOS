//
//  ProfileVC.swift
//  Polink
//
//  Created by Josh Valdivia on 18/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import SafariServices

class ProfileVC: UIViewController {
	
	private let defaults = UserDefaults.standard
	private let currentUser: User
	private let db = Firestore.firestore()
	private var historyRef: CollectionReference {
		return db.collection("history")
	}
	
	init(user: User) {
		self.currentUser = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	enum Section: String, CaseIterable {
		case profile, history
	}
	
	enum ItemType {
		case statistics, logout, pastConversation, updateHistory, privacyNotice
	}
	
	struct Item: Hashable {
		
		let title: String
		let type: ItemType
		let conversation: Room?
		private let identifier: UUID
		
		
		init(title: String, type: ItemType) {
			self.title = title
			self.type = type
			self.conversation = nil
			self.identifier = UUID()
		}
		
		init(conversation: Room) {
			
			self.title = conversation.id
			self.type = .pastConversation
			self.conversation = conversation
			self.identifier = UUID()
		}
		
		var isRoom: Bool {
			return type == .pastConversation
		}
		
		var isUpdate: Bool {
			return type == .updateHistory
		}
		
		var isLogout: Bool {
			return type == .logout
		}
		
		var isStatistics: Bool {
			return type == .statistics
		}
		
		func hash(into hasher: inout Hasher) {
			hasher.combine(self.identifier)
		}
	}
	
	var rooms = [Room]()
	var pastConversations: [Item]?
	
	
	let tableView = UITableView(frame: .zero, style: .insetGrouped)
	var dataSource: DiffableDataSource! = nil
	var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Item>! = nil
	
	var firstSectionItems: [Item] = {
		return [
			Item(title: "Profile - Statistics", type: .statistics),
			Item(title: "Logout", type: .logout)]
	}()
	
	var updateHistory: Item {
		Item(title: "Update History", type: .updateHistory)
	}
	
	static let reuseIdentifier = "reuse-identifier"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		tableView.delegate = self
		configureDataSource()
		configureTableView()
		pastConversations = [updateHistory]
		updateUI(animated: false)
	}
	
}

extension ProfileVC  {
	func configureDataSource() {
		self.dataSource = DiffableDataSource(tableView: tableView) { (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
						
			let cell = tableView.dequeueReusableCell(withIdentifier: ProfileVC.reuseIdentifier, for: indexPath)
			
			// Past conversation cells
			if item.isRoom {
				let formatter = DateFormatter()
				formatter.dateStyle = .medium
				cell.textLabel?.text = "Conversation - " + formatter.string(from:item.conversation!.createdAt)
				cell.accessoryType = .disclosureIndicator
				cell.accessoryView = nil
				
				// first section cells
			} else if item.isStatistics {
				cell.textLabel?.text = item.title
				cell.accessoryType = .disclosureIndicator
			} else if item.isLogout {
				cell.textLabel?.text = item.title
				cell.textLabel?.textColor = .red
				cell.textLabel?.tintColor = .red
				cell.accessoryType = .none
			} else if item.isUpdate {
				cell.textLabel?.text = item.title
				cell.backgroundColor = .black
				cell.textLabel?.textColor = .white
				cell.textLabel?.textAlignment = .center
				cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .medium)
				cell.accessoryType = .none
			} else {
				fatalError("Unknown item type!")
			}
			return cell
		}
		
		self.dataSource.defaultRowAnimation = .fade
		print("finished configuring data source")
	}
	
	func updateUI(animated: Bool = true) {
		let profileItems = firstSectionItems
		
		currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
		
		currentSnapshot.appendSections([Section.profile])
		currentSnapshot.appendItems(profileItems, toSection: .profile)
		
		if pastConversations != nil {
			currentSnapshot.appendSections([.history])
			currentSnapshot.appendItems(pastConversations!, toSection: .history)
		}
		
		self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
		
	}
	
	func updateHistoryItems() {
		historyRef.whereField("participants", arrayContains: currentUser.uid).whereField("reported", isEqualTo: false).whereField("finished", isEqualTo: true).getDocuments { (QuerySnapshot, error) in
			guard let snapshot = QuerySnapshot else {
				print("Error getting history: \(error?.localizedDescription ?? "No error")")
				return
			}
			
			snapshot.documentChanges.forEach { (change) in
				print("There are changes")
				self.handleDocumentChange(change)
			}
		}
//		guard let index = pastConversations?.firstIndex(of: updateHistory) else { return }
//		pastConversations?.remove(at: index)
	}
	
	func handleDocumentChange(_ change: DocumentChange) {
		do {
			guard let room: Room = try change.document.data(as: Room.self) else {return}
			
			switch change.type {
			case .added:
				print("We add")
				addRoomToHistory(room)
			case .modified:
				print("We modify")
				updateRoomInHistory(room)
			case .removed:
				print("We remove")
				removeRoomFromHistory(room)
			}
		} catch {
			print("There was a problem handling the document change and decoding into history room object: \(error.localizedDescription)")
		}
		updateUI()
	}
	
	func addRoomToHistory(_ room: Room) {
		guard !rooms.contains(room) else {return}
		
		rooms.append(room)
		rooms.sort()
		
		guard let index = rooms.firstIndex(of: room) else {return}
		
		let newItem = Item(conversation: room)
		
		pastConversations?.insert(newItem, at: index + 1)
	}
	
	func updateRoomInHistory(_ room: Room) {
		guard let index = rooms.firstIndex(of: room) else {return}
		
		rooms[index] = room
		
		let updatedItem = Item(conversation: room)
		pastConversations?[index] = updatedItem
	}
	
	func removeRoomFromHistory(_ room: Room) {
		guard let index = rooms.firstIndex(of: room) else {return}
		rooms.remove(at: index)
		pastConversations?.remove(at: index)
	}

}

extension ProfileVC: UITableViewDelegate {
	func configureTableView() {
		view.addSubview(tableView)
		tableView.contentInset.top = -15
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
		])
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: ProfileVC.reuseIdentifier)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		guard let rowItem = dataSource.itemIdentifier(for: indexPath) else {return}
		
		switch rowItem.type {
		case .updateHistory:
			//update history
			updateHistoryItems()
			for item in pastConversations! {
				print(item.title)
			}
		case .logout:
			let alert = UIAlertController(title: "Logging out?", message: "You can always log back in with your registered email and password", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Nevermind", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [unowned self] (action) in
				do {
					try Auth.auth().signOut()
					self.defaults.set(false, forKey: "LOGGED_IN")
					let mainSB = UIStoryboard(name: "Main", bundle: nil)
					let vc = mainSB.instantiateViewController(identifier: "initialViewController") as! InitialVC
					UIApplication.shared.windows.first {$0.isKeyWindow}?.rootViewController = vc
				} catch {
					print("Couldn't Sign out")
				}
			}))
			present(alert, animated: true, completion: nil)
		case .statistics:
			let userRef = db.collection("users").document(currentUser.uid)
			userRef.getDocument { [unowned self] (document, error) in
				do {
					guard let profile = try document?.data(as: ProfilePublic.self) else {return}
					let vc = ProfileDetailViewController(profile, delegate: self)
					
					let navController = UINavigationController(rootViewController: vc)
					navController.presentationController?.delegate = self
					self.present(navController, animated: true, completion: nil)
				} catch {
					print("Couldn't decode document into public profile: \(error.localizedDescription)")
				}
			}
			print("This is statistics")
		case .pastConversation:
			print("This is a past conversation")
		case .privacyNotice:
			if let url = URL(string: "https://polink.flycricket.io/privacy.html") {
				let config = SFSafariViewController.Configuration()
				config.entersReaderIfAvailable = true
				
				let vc = SFSafariViewController(url: url, configuration: config)
				vc.modalPresentationStyle = .popover
				self.present(vc, animated: true, completion: nil)
			}
		}
	}
	
}

extension ProfileVC: ProfileDetailViewControllerDelegate {
	func dismissProfileDetailViewController(_ controller: ProfileDetailViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

extension ProfileVC: UIAdaptivePresentationControllerDelegate {
	
}

class DiffableDataSource: UITableViewDiffableDataSource<ProfileVC.Section, ProfileVC.Item> {
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return ProfileVC.Section.allCases[section].rawValue.uppercased()
	}
}
