//
//  HomeVC.swift
//  Polink
//
//  Created by Josh Valdivia on 18/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

protocol HomeVCDelegate: UITableViewController {
	func matchingDataIsPassed(userProfiles: [(String, Double)])
}

class HomeVC: UIViewController {
	
	let matchButton = UIButton(type: .roundedRect)
	let listeningSwitch = UISwitch()
	let switchTitle = UILabel()
	
	// Initialising the firestore database
	let db = Firestore.firestore()
	private let currentUser : User
	private var userRef : DocumentReference?
	private var userProfile : ProfilePublic?
	private var userProfileListener: ListenerRegistration?
	private var userHandler: AuthStateDidChangeListenerHandle?
	private var profileDistances: [(String,Double)]?
	
	// Delegate for passing information to LobbyVC
	weak var delegate : HomeVCDelegate?
	
	init(user: User) {
		self.currentUser = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		userProfileListener?.remove()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setButton()
		setUpSwitch()
		userRef = db.collection("users").document(currentUser.uid)
		
		navigationController?.setNavigationBarHidden(true, animated: false)
		// Do any additional setup after loading the view.
		
		userProfileListener = userRef?.addSnapshotListener(includeMetadataChanges: false, listener: { (QuerySnapshot, error) in
			guard let snapshot = QuerySnapshot else {
				print("Error listening for user's public profile updates: \(error?.localizedDescription ?? "No error")")
				return
			}
			do {
				self.userProfile = try snapshot.data(as: ProfilePublic.self)
				print(String(describing: self.userProfile))
				self.listeningSwitch.setOn(self.userProfile!.listening, animated: true)
			} catch {
				print("Found error decoding data to local variable userProfile: \(error.localizedDescription)")
			}
		})
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	
	
	@objc func didPressMatchButton() {
		matchButton.pulsate()
		print(userRef?.path as Any)
		do {
			try getUsersInArea()
		} catch {
			print(error.localizedDescription)
		}
	}
	
	@objc private func switchValueDidChange(_ sender:UISwitch) {
		
		guard let userIsListening = userProfile?.listening else { return }
		
		do {
			if sender.isOn && userIsListening {
				return
			} else if sender.isOn && !userIsListening {
				userProfile?.listening = true
				matchButton.isEnabled = true
				try userRef?.setData(from: userProfile)
			} else if !sender.isOn && !userIsListening {
				return
			} else {
				userProfile?.listening = false
				matchButton.isEnabled = false
				try userRef?.setData(from: userProfile)
			}
		} catch {
			print("Couldn't write listening state to database: \(error.localizedDescription)")
		}

	}
	
	func setButton() {
		view.addSubview(matchButton)
		matchButton.translatesAutoresizingMaskIntoConstraints = false
		matchButton.titleLabel?.text = "Match!"
		matchButton.backgroundColor = .green
		matchButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
		matchButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
		matchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		matchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		matchButton.addTarget(self, action: #selector(didPressMatchButton), for: .touchUpInside)
	}
	
	func setUpSwitch() {
		view.addSubview(listeningSwitch)
		
		listeningSwitch.translatesAutoresizingMaskIntoConstraints = false
		listeningSwitch.onTintColor = .green
		listeningSwitch.topAnchor.constraint(equalTo: matchButton.bottomAnchor, constant: 50).isActive = true
		listeningSwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
		listeningSwitch.isUserInteractionEnabled = true
		listeningSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
		
		view.addSubview(switchTitle)
		switchTitle.translatesAutoresizingMaskIntoConstraints = false
		switchTitle.bottomAnchor.constraint(equalTo: listeningSwitch.topAnchor, constant: -10).isActive = true
		switchTitle.rightAnchor.constraint(equalTo: listeningSwitch.rightAnchor).isActive = true
		switchTitle.tintColor = .black
	}
	
	// MARK: - Spinner View Lifecycle
	
	func createSpinnerView() -> SpinnerVC{
		let child = SpinnerVC()
		addChild(child)
		child.view.fillSuperview()
		view.addSubview(child.view)
		child.didMove(toParent: self)
		return child
	}
	
	func removeSpinnerView(spinnerView: SpinnerVC) {
		spinnerView.willMove(toParent: nil)
		spinnerView.view.removeFromSuperview()
		spinnerView.removeFromParent()
	}
	
	// MARK: - Helpers
	
	func getUsersInArea() throws -> Void {
		// Create Spinner View to block user interactions
		guard let userProfile = userProfile else { return }
		
		db.collectionGroup("users")
			.whereField("country", isEqualTo: userProfile.country)
			.whereField("listening", isEqualTo: true).getDocuments { (QuerySnapshot, error) in
				guard let documents = QuerySnapshot else {
					print("There was an error retrieving the user profiles from the database: \(String(describing: error?.localizedDescription))")
					return
				}
				do {
					let decodedDocuments: [ProfilePublic] = try documents.decoded()
					var distanceCalculator = DistanceCalculator(user: userProfile)
					for profile in decodedDocuments {
						if profile.uid == userProfile.uid {continue}		// If profile matches user id -> skip it
						print(String(describing: profile.ideology))
						// Store the results and keep a copy
						let distancePoint = DistancePoint(source: profile)
						distanceCalculator.addDistancePointToCollection(point: distancePoint)
					}
					distanceCalculator.calculateDistances()
					// Get the array of distances from the DistanceCalculator
					self.profileDistances = distanceCalculator.getProfileDistances()
					// Call a delegate method to send the information to LobbyVC and present that view
					self.matchUsers()
				} catch {
					print("Something went wrong whilst decoding the information stored in the database:\(error.localizedDescription)")
				}
		}
		
		//		let spinnerView = createSpinnerView()
		//
		//		//	db.collectionGroup("users").whereField("country", isEqualTo: user.country)
		//
		//		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
		//			// Remove the Spinner view
		//			self.removeSpinnerView(spinnerView: spinnerView)
		//		}
		//
	}
	
	func matchUsers() {
		if profileDistances == nil {
			return
		}
		print("Matching users")
		guard let nc = (tabBarController?.viewControllers?[0])! as? NavigationController else {
			return
		}
		guard let vc = nc.viewControllers[0] as? LobbyVC else {return}
		
		self.delegate = vc
		
		// Switch to LobbyVC
		tabBarController?.selectedIndex = 0
		
		// Pass data to LobbyVC
		Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (Timer) in
			self.delegate?.matchingDataIsPassed(userProfiles: self.profileDistances!)
		}
	}
	
}
