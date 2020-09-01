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
import FirebaseFunctions
import RealmSwift

protocol HomeVCDelegate: UITableViewController {
	func matchingDataIsPassed(userProfiles: [(String, Double)])
}

class HomeVC: UIViewController {

	private var observer: NSKeyValueObservation?
	private var presentationAnimationController: PopupPresentationAnimationController?
	private let defaults = UserDefaults.standard

	var mainLabel: UILabel = {
		let label = UILabel(frame: CGRect(0, 0, 100, 100))
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.text = K.appName
		label.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
		label.layer.shadowOffset = CGSize(width: 2, height: 2)
		label.layer.shadowColor = UIColor.lightGray.cgColor
		return label
	}()
	
	var statistics: MainStatistics?
	let matchButton = UIButton(type: .roundedRect)
	
	// Lazy var for Firebase functions
	fileprivate lazy var functions = Functions.functions()
	
	// Initialising the firestore database
	let db = Firestore.firestore()
	private var currentUser : User
	private var userRef : DocumentReference?
	private var userProfile : ProfilePublic? {
		didSet {
			compareAndUpdateFCM(userProfile)
		}
	}
	private var userProfileListener: ListenerRegistration?
	private var userHandler: AuthStateDidChangeListenerHandle?
	private var profileDistances: [(String,Double)]?
	private lazy var realm = try! Realm()
	
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
		observer?.invalidate()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		
		let application = UIApplication.shared

		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(
			options: authOptions,
			completionHandler: {_, _ in })

		application.registerForRemoteNotifications()
		
		setupViews()
		setupConstraints()
		updateButton()
		
		RealmUtil.setDefaultRealmForUser(username: currentUser.uid)

		userRef = db.collection("users").document(currentUser.uid)
		navigationController?.setNavigationBarHidden(true, animated: false)
		// Do any additional setup after loading the view.
		
		userProfileListener = userRef?.addSnapshotListener(includeMetadataChanges: false, listener: { [weak self] (QuerySnapshot, error) in
			guard let snapshot = QuerySnapshot else {
				print("Error listening for user's public profile updates: \(error?.localizedDescription ?? "No error")")
				return
			}
			do {
				self?.userProfile = try snapshot.data(as: ProfilePublic.self)
				self?.defaults.set(self?.userProfile?.listening, forKey: "USER_LISTENING")
				self?.updateButton()
			} catch {
				print("Found error decoding data to local variable userProfile: \(error.localizedDescription)")
			}
		})
	
		statistics?.didPressStatsButton(UIButton())
		
		if let config = realm.object(ofType: ConfigurationObject.self, forPrimaryKey: "onboarded") {
			if config.value == false {
				let onboardingViewController = MainOnboardViewController(delegate: self)
				onboardingViewController.hidesBottomBarWhenPushed = true
				self.navigationController?.fadeTo(onboardingViewController)
			} else {
				print(config.value)
			}
		} else {
			let onboardingViewController = MainOnboardViewController(delegate: self)
			onboardingViewController.hidesBottomBarWhenPushed = true
			self.navigationController?.fadeTo(onboardingViewController)
		}
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
	
	func setupViews() {
		view.addSubview(mainLabel)
		mainLabel.translatesAutoresizingMaskIntoConstraints = false
		mainLabel.text = K.appName
		
		view.addSubview(matchButton)
		matchButton.translatesAutoresizingMaskIntoConstraints = false
		matchButton.setTitle("Match", for: .normal)
		matchButton.setTitle("Not Listening", for: .disabled)
		matchButton.setTitleColor(.white, for: .normal)
		matchButton.setTitleColor(.lightGray, for: .disabled)
		matchButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		matchButton.layer.cornerRadius = 25
		matchButton.layer.shadowOffset = CGSize(width: 2, height: 2)
		matchButton.layer.shadowColor = UIColor.lightGray.cgColor
		matchButton.layer.shadowRadius = 5
		matchButton.layer.shadowOpacity = 0.5
		matchButton.addTarget(self, action: #selector(didPressMatchButton), for: .touchUpInside)
		
		statistics = MainStatistics(self)
		guard let stats = statistics else {return}
		view.addSubview(stats)
	}
	
	func setupConstraints() {
		NSLayoutConstraint.activate([
			matchButton.heightAnchor.constraint(equalToConstant: 100),
			matchButton.widthAnchor.constraint(equalToConstant: 150),
			matchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			matchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 150),
			
			mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
			mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
			mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
			mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])
		
		guard let stats = statistics else {return}
		NSLayoutConstraint.activate([
			stats.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 20),
			stats.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			stats.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			stats.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stats.bottomAnchor.constraint(equalTo: matchButton.topAnchor, constant: -10)
		])
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
			.whereField("listening", isEqualTo: true).getDocuments { [weak self] (QuerySnapshot, error) in
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
					self?.profileDistances = distanceCalculator.getProfileDistances()
					// Call a delegate method to send the information to LobbyVC and present that view
					self?.matchUsers()
				} catch {
					print("Something went wrong whilst decoding the information stored in the database:\(error.localizedDescription)")
				}
		}
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
	
	func compareAndUpdateFCM(_ currentUserProfile: ProfilePublic?) {
		let fcmToken = defaults.string(forKey: "FCM_TOKEN")
		if currentUserProfile?.fcm != fcmToken {
			userRef?.updateData(["fcm": fcmToken ?? ""]) { err in
				if let err = err {
					print(err.localizedDescription)
				} else {
					self.defaults.set(fcmToken, forKey: "FCM_TOKEN")
					print("FCM token uploaded to server successfully")
				}
			}
		}
	}
	
	func updateButton() {
		if defaults.bool(forKey: "USER_LISTENING") {
			print("defaults bool is true")
			self.matchButton.isEnabled = true
			self.matchButton.backgroundColor = .black
		} else {
			print("defaults bool is false")
			self.matchButton.isEnabled = false
			self.matchButton.backgroundColor = .white
		}
	}
	
}

extension HomeVC: UIViewControllerTransitioningDelegate {
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

extension HomeVC: MainStatisticsDelegate {
	
	func getHistoryData(_ completion: @escaping (String, [Room]) -> ()) throws {
		var rooms: [Room] = []
		db.collection("history").whereField("reported", isEqualTo: false).whereField("participants", arrayContains: currentUser.uid).getDocuments { (querySnapshot, error) in
			guard let documents = querySnapshot else {return}
			do {
				for document in documents.documents {
					guard let r = try document.data(as: Room.self) else {return}
					rooms.append(r)
				}
				completion(self.currentUser.uid, rooms)
			} catch {
				print("Decoding rooms is failing", error.localizedDescription)
			}
		}
	}

	func getCurrentUserID() -> String {
		currentUser.uid
	}
}

extension HomeVC: ProfileVCDelegate {
	func updateListeningMode(listening: Bool) {
		userRef?.updateData(["listening": listening]) { err in
			if let err = err {
				print(err.localizedDescription)
			} else {
				print("Document updated successfully")
			}
		}
	}
}

extension HomeVC: MainOnboardViewControllerDelegate {
	
}
