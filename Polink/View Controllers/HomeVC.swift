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

class HomeVC: UIViewController {
	
	let matchButton = UIButton(type: .roundedRect)
	let listeningSwitch = UISwitch()
	let switchTitle = UILabel()
	
	// Initialising the firestore database
	let db = Firestore.firestore()
	private let currentUser : User
	var userRef : DocumentReference?
	var userProfile : ProfilePublic?
	var userProfileListener: ListenerRegistration?
	var userHandler: AuthStateDidChangeListenerHandle?
	
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
			let users = try getUsersInArea()
			if users.first == nil {
				print("Users are empty!")
			} else {
				print(users)
			}
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
	
	func getUsersInArea() throws -> [ProfilePublic]{
		// Create Spinner View to block user interactions
		let spinnerView = createSpinnerView()
		
		//	db.collectionGroup("users").whereField("country", isEqualTo: user.country)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
			// Remove the Spinner view
			self.removeSpinnerView(spinnerView: spinnerView)
		}
		
		return []
	}
	
	func updateUI() {

	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destination.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
