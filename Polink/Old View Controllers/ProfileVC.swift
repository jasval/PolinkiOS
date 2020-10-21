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
import RealmSwift

protocol ProfileVCDelegate: class {
	func updateListeningMode(listening: Bool)
}

class ProfileVC: UIViewController {
	
	private var observer: NSKeyValueObservation?
	private lazy var realm = try! Realm()
	private var profileIsIncomplete: Bool = false
	private var delegate: ProfileVCDelegate?
	private let defaults = UserDefaults.standard
	private let currentUser: User
	private let db = Firestore.firestore()
	private var userRef : DocumentReference?
	private var userProfile : ProfilePublic?
	private var userProfileListener: ListenerRegistration?
	private var historyRef: CollectionReference {
		return db.collection("history")
	}
	
	private var listeningSwitch: UISwitch = {
		let switchView = UISwitch(frame: .zero)
		switchView.translatesAutoresizingMaskIntoConstraints = false
		switchView.onTintColor = .black
		return switchView
	}()
	
	init(user: User, delegate: ProfileVCDelegate) {
		self.delegate = delegate
		self.currentUser = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		userProfileListener?.remove()
		observer?.invalidate()
	}

	enum Section: String, CaseIterable {
		case profile, alert, history
	}
	
	enum ItemType {
		case statistics, logout, pastConversation, updateHistory, privacyPolicy, listening, completeProfile
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
		
		var isPrivacyPolicy: Bool {
			return type == .privacyPolicy
		}
		
		var isListening: Bool {
			return type == .listening
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
	
	lazy var firstSectionItems: [Item] = {
		return [
			Item(title: "Profile - Statistics", type: .statistics),
			Item(title: "Listening", type: .listening),
			Item(title: "Privacy Policy", type: .privacyPolicy),
			Item(title: "Logout", type: .logout)]
	}()
	
//	lazy var secondSectionItems: [Item] = {
//		return [
//			Item(title: "Complete your profile", type: .completeProfile)
//		]
//	}()
	
	lazy var updateHistory: Item = {
		Item(title: "Update History", type: .updateHistory)
	}()
	
	static let reuseIdentifier = "reuse-identifier"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		tableView.delegate = self
		
		
		let objects = realm.objects(QuestionObject.self)
		if objects.count < 60 {
			profileIsIncomplete = true
		}
		
		observer = defaults.observe(\.userIsListening,
									options: [.initial, .new],
									changeHandler: { [weak self] (defaults, change) in
			let listening = defaults.bool(forKey: "USER_LISTENING")
			print("There has been a change")
			self?.listeningSwitch.setOn(listening, animated: false)
		})

		configureDataSource()
		configureTableView()
		pastConversations = [updateHistory]
		updateHistoryItems()
		updateUI(animated: false)
	}
	
}

extension ProfileVC  {
	func configureDataSource() {
		self.dataSource = DiffableDataSource(tableView: tableView) {
			
			[weak self] (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
						
			let cell = tableView.dequeueReusableCell(withIdentifier: ProfileVC.reuseIdentifier,
													 for: indexPath)
			
			switch item.type {
			case .pastConversation:
				let formatter = DateFormatter()
				formatter.dateStyle = .medium
				cell.textLabel?.text = "Conversation - " + formatter.string(from:item.conversation!.createdAt)
				cell.accessoryType = .disclosureIndicator
				cell.accessoryView = nil
			case .statistics:
				cell.textLabel?.text = item.title
				cell.accessoryType = .disclosureIndicator
			case .logout:
				cell.textLabel?.text = item.title
				cell.textLabel?.textColor = .red
				cell.textLabel?.tintColor = .red
				cell.accessoryType = .none
			case .updateHistory:
				cell.textLabel?.text = item.title
				cell.backgroundColor = .black
				cell.textLabel?.textColor = .white
				cell.textLabel?.textAlignment = .center
				cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize,
														 weight: .medium)
				cell.accessoryType = .none
			case .privacyPolicy:
				cell.textLabel?.text = item.title
				cell.accessoryType = .disclosureIndicator
			case .listening:
				cell.textLabel?.text = item.title
				cell.accessoryView = self?.listeningSwitch
				self?.listeningSwitch.addTarget(self,
												action: #selector(self?.switchValueDidChange(_:)),
												for: .valueChanged)
			case .completeProfile:
				cell.textLabel?.text = item.title
				cell.backgroundColor = #colorLiteral(red: 1, green: 0.6784313725, blue: 0.09411764706, alpha: 1)
				cell.textLabel?.textAlignment = .center
				cell.textLabel?.textColor = .white
				cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize,
														 weight: .medium)
				cell.accessoryType = .none
			}
			return cell
		}
		
		self.dataSource.defaultRowAnimation = .fade
		print("finished configuring data source")
	}
	
	func updateUI(animated: Bool = true) {
		
		currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
		
		currentSnapshot.appendSections([Section.profile])
		currentSnapshot.appendItems(firstSectionItems, toSection: .profile)
		
		if profileIsIncomplete {
			currentSnapshot.appendSections([Section.alert])
			currentSnapshot.appendItems([Item(title: "Complete your profile",
											  type: .completeProfile)])
		}
		
		if pastConversations != nil {
			currentSnapshot.appendSections([.history])
			currentSnapshot.appendItems(pastConversations!, toSection: .history)
		}
		
		self.dataSource.apply(currentSnapshot, animatingDifferences: animated)
		
	}
	
	func updateHistoryItems() {
		historyRef.whereField("participants",
							  arrayContains: currentUser.uid)
									.whereField("reported", isEqualTo: false)
									.whereField("finished", isEqualTo: true)
									.getDocuments
			{ (QuerySnapshot, error) in
				
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
	
	@objc private func switchValueDidChange(_ sender :UISwitch) {
		delegate?.updateListeningMode(listening: sender.isOn)
	}

}

extension ProfileVC: UITableViewDelegate {
	func configureTableView() {
		view.addSubview(tableView)
		tableView.contentInset.top = 10
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
			let alert = UIAlertController(title: "Logging out?",
										  message: "You can always log back in with your registered email and password",
										  preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Nevermind",
										  style: .cancel,
										  handler: nil))
			alert.addAction(UIAlertAction(title: "Log Out",
										  style: .destructive,
										  handler: { (action) in
				do {
					try Auth.auth().signOut()
					let vc = LogSignViewController()
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
					var vc = ProfileDetailViewController(profile, delegate: self)
					if self.rooms.count > 0 {
						var ideologyMapping = IdeologyMapping(econ: 0, dipl: 0, scty: 0, govt: 0)
						var index = 0.0
						for room in self.rooms {
							guard let other = (room.participantFeedbacks.first { (participant) -> Bool in
								participant.uid != self.currentUser.uid
							}) else {return}
							ideologyMapping.dipl += other.perceivedIdeology.dipl
							ideologyMapping.econ += other.perceivedIdeology.econ
							ideologyMapping.govt += other.perceivedIdeology.govt
							ideologyMapping.scty += other.perceivedIdeology.scty
							index += 1.0
						}
						ideologyMapping.econ = ideologyMapping.econ / index
						ideologyMapping.govt = ideologyMapping.govt / index
						ideologyMapping.scty = ideologyMapping.scty / index
						ideologyMapping.dipl = ideologyMapping.dipl / index

						vc = ProfileDetailViewController(profile,
														 aggregatedFeedback: ideologyMapping,
														 delegate: self)
					}

					let navController = UINavigationController(rootViewController: vc)
					navController.presentationController?.delegate = self
					self.present(navController, animated: true, completion: nil)
				} catch {
					print("Couldn't decode document into public profile: \(error.localizedDescription)")
				}
			}
			print("This is statistics")
		case .pastConversation:
			let userRef = db.collection("users").document(currentUser.uid)
			userRef.getDocument { [unowned self] (document, error) in
				do {
					guard let profile = try document?.data(as: ProfilePublic.self) else {return}
					
					let vc = PastConversationDetailVC(rowItem.conversation!,
													  profile: profile,
													  delegate: self)
					
					let navController = UINavigationController(rootViewController: vc)
					navController.presentationController?.delegate = self
					self.present(navController, animated: true, completion: nil)
				} catch {
					print("Couldn't decode document into public profile: \(error.localizedDescription)")
				}
			}
			print("This is a past conversation")
		case .privacyPolicy:
			if let url = URL(string: "https://polink.flycricket.io/privacy.html") {
				let config = SFSafariViewController.Configuration()
				config.entersReaderIfAvailable = true
				
				let vc = SFSafariViewController(url: url, configuration: config)
				vc.modalPresentationStyle = .popover
				self.present(vc, animated: true, completion: nil)
			}
		case .listening:
			break
		case .completeProfile:
			print("Starting to query")
			let userRef = db.collection("users").document(currentUser.uid)
			userRef.getDocument(completion: { [weak self] (documentSnapshot, error) in
				if let error = error {
					print(error.localizedDescription)
				}
				do {
					print(documentSnapshot.debugDescription)
					self?.userProfile = try documentSnapshot?.data(as: ProfilePublic.self)
					print("Present the view controller")
					let questionObjects = self?.realm.objects(QuestionObject.self)
					let vc = PoliticalQuizVC(questions: questionObjects!,
											 userIdeology: (self?.userProfile!.ideology!)!,
											 delegate: self!) {
												self?.navigationController?.navigationBar.isHidden = false
												self?.updateUI()
												self?.navigationController?.fadeFrom()
					}
					vc.hidesBottomBarWhenPushed = true
					self?.navigationController?.fadeTo(vc)
				} catch {
					fatalError(error.localizedDescription)
				}
			})
		}
	}
	
}

extension ProfileVC: PastConversationDetailDelegate {
	func dismissDetailViewController(_ controller: PastConversationDetailVC) {
		controller.dismiss(animated: true, completion: nil)
	}
}

extension ProfileVC: ProfileDetailViewControllerDelegate {
	func dismissProfileDetailViewController(_ controller: ProfileDetailViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

extension ProfileVC: PoliticalQuizVCDelegate {
	func politicalQuizViewController(didSave questionObjects: [Question]) {
		do {
			let container = try Container(userID: currentUser.uid)
			try container.write { (transaction) in
				for question in questionObjects {
					transaction.add(question, update: .modified)
				}
			}
		} catch {
			fatalError(error.localizedDescription)
		}
	}
}

extension ProfileVC: UIAdaptivePresentationControllerDelegate {}

class DiffableDataSource: UITableViewDiffableDataSource<ProfileVC.Section, ProfileVC.Item> {
//	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return ProfileVC.Section.allCases[section].rawValue.uppercased()
//	}
}
