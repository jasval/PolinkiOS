//
//  QuizVC.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class QuizVC: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var quizProgress: UIProgressView!
	@IBOutlet var buttons: [UIButton]! = []
	@IBOutlet weak var quizLabel: UILabel!
	@IBOutlet weak var answerStack: UIStackView!
	@IBOutlet weak var backButton: UIButton!
	
	// creating an instance of the QuizBrain
	var quiz = QuizBrain()
	
	// initialising the firestore database
	let db = Firestore.firestore()
	
	//handler of the auth state listener
	var handle: AuthStateDidChangeListenerHandle?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// progress bar styling and initialisation
		print(Registration.state.dob?.description as Any)
		print(Registration.state.polinkIdeology?.description as Any)
		quizProgress.progress = 0
		quizProgress.transform = quizProgress.transform.scaledBy(x: 1, y: 4)
		quizProgress.layer.masksToBounds = true
		quizProgress.layer.cornerRadius = quizProgress.frame.height / 2
		quizProgress.alpha = 0
		
		// creating the answerButtons
		for i in 1...5 {
			let button = AnswerButton(position: i)
			answerStack.addArrangedSubview(button)
			button.addTarget(self, action: #selector(answerButtonPressed(_:)), for: .touchUpInside)
			buttons.append(button)
		}
		
		// initialising the backButton
		backButton.layer.masksToBounds = true
		backButton.layer.cornerRadius = backButton.frame.height / 5
		backButton.alpha = 0
		
		// setting initial labels
		titleLabel.text = "Hello, \(Registration.state.fname ?? "New User")"
		titleLabel.alpha = 0.0
		quizLabel.text =
		"""
		We are going to ask you a few quetions so we can get to know you better.
		\nThere are no right or wrong answers, just be honest and allow us to do the rest.
		"""
		
		quizLabel.alpha = 0
	}
	
	override func viewWillAppear(_ animated: Bool) {
		handle = Auth.auth().addStateDidChangeListener { (auth, user) in
			// ...
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		UIView.animate(withDuration: 2) {
			self.titleLabel.alpha = 1
		}
		UIView.animate(withDuration: 2, delay: 0.5, animations: {
			self.quizLabel.alpha = 1
		}, completion: nil)
		
		Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { (Timer) in
			UIView.animate(withDuration: 2, animations: {
				self.titleLabel.alpha = 0
				self.quizLabel.alpha = 0
			}, completion: nil)
		}
		Timer.scheduledTimer(withTimeInterval: 9, repeats: false, block: {(Timer) in
			self.startQuiz()
		})
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		Auth.auth().removeStateDidChangeListener(handle!)
	}
	
	@IBAction func answerButtonPressed(_ sender: AnswerButton){
		// Backend tracking in QuizBrain
		quiz.nextQuestion(sender.effect!)
		loadQuestion()
		updateProgressBar()
	}
	
	@IBAction func backButtonPressed(_ sender: UIButton) {
		// Back Button
		quiz.prevQuestion()
		loadQuestion()
		updateProgressBar(-1)
		
	}
	
	func startQuiz () {
		quiz.initQuiz()
		loadQuestion()
		var delayCounter:Float = 1
		for button in buttons {
			animateIn(button, delay: 1 + delayCounter)
			delayCounter += 0.5
		}
		animateIn(quizProgress, delay: 5)
		animateIn(backButton, delay: 6)
		
	}
	
	func loadQuestion() {
		animateOutQ()
		if quiz.questionNo < quiz.quizList.count {
			quizLabel.text = quiz.quizList[quiz.questionNo].prompt
			titleLabel.text = "Question: \(quiz.questionNo + 1)"
			animateInQ()
		} else {
			do{
				let finalScore = try quiz.calcScores()
				// Printing and declaration of lastScore for testing
				let lastScore = quiz.answerStack.peek()
				print("End of questions")
				print("Max diplomacy score is \(quiz.maxDipl)")
				print("Your raw diplomacy score is: \(lastScore!.dipl)")
				print("Your calculated diplomacy score is: \(finalScore.dipl)%")
				print("Max economy score is \(quiz.maxEcon)")
				print("Your raw economy score is: \(lastScore!.econ)")
				print("Your calculated economy score is: \(finalScore.econ)%")
				print("Max government score is: \(quiz.maxGovt)")
				print("Your raw government score is: \(lastScore!.govt)")
				print("Your calculated government score is: \(finalScore.govt)%")
				print("Max societal score is: \(quiz.maxScty)")
				print("Your raw societal score is: \(lastScore!.scty)")
				print("Your calculated societal score is: \(finalScore.scty)%")
				for button in buttons {
					animateOut(button)
				}
				var dictionary: [String: Double] = [:]
				dictionary.updateValue(finalScore.dipl, forKey: K.ideologyAxes.dipl)
				dictionary.updateValue(finalScore.econ, forKey: K.ideologyAxes.econ)
				dictionary.updateValue(finalScore.govt, forKey: K.ideologyAxes.govt)
				dictionary.updateValue(finalScore.scty, forKey: K.ideologyAxes.scty)
				
				Registration.state.polinkIdeology = dictionary
				
				animateOut(quizProgress)
				displayResults()
				sendResults()
			} catch {
				print(error)
			}
		}
	}
	
	func displayResults(){
		let resultsLabel = UILabel()
		self.view.addSubview(resultsLabel)
		resultsLabel.translatesAutoresizingMaskIntoConstraints = false
		resultsLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
		resultsLabel.heightAnchor.constraint(equalToConstant: 300).isActive = true
		resultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		resultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		resultsLabel.textAlignment = NSTextAlignment.center
		resultsLabel.numberOfLines = 0
		resultsLabel.alpha = 0
		resultsLabel.text = "Diplomacy Score: \(Registration.state.polinkIdeology?[K.ideologyAxes.dipl] ?? 0)\nEconomy Score: \(Registration.state.polinkIdeology?[K.ideologyAxes.econ] ?? 0)\nGovernment Score: \(Registration.state.polinkIdeology?[K.ideologyAxes.govt] ?? 0)\nSociety Score: \(Registration.state.polinkIdeology?[K.ideologyAxes.scty] ?? 0)"
		animateIn(resultsLabel, delay: 1)
	}
	func displayNextButton() {
		let nextButton = UIButton(type: .roundedRect)
		nextButton.backgroundColor = UIColor.gray
		nextButton.setTitle("Next", for: .normal)
		nextButton.setTitleColor(UIColor.white, for: .normal)
		nextButton.alpha = 0
		self.view.addSubview(nextButton)
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nextButton.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		nextButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
		nextButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
		nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
		animateIn(nextButton, delay: 3)
	}
	
	func sendResults() {
		let userId = Auth.auth().currentUser?.uid
		let userEmail =  Auth.auth().currentUser?.email
		let r = Registration.state
		if let userId = userId, let userEmail = userEmail {
			let userPublic = ProfilePublic(uid: userId, country: r.geoLocCountry ?? "United Kingdom", city: r.geoLocCity ?? "London", ideology: r.polinkIdeology, listening: true, redFlags: 0)
			let userPrivate = ProfilePrivate(email: userEmail, firstName: r.fname!, lastName: r.lname!, gender: r.gender!, createdAt: Date(), dateOfBirth: r.dob!)
			do {
				// Create a write batch
				let batch = db.batch()
				
				// Set values for user's public profile
				let publicRef = db.collection("users").document(userId)
				try batch.setData(from: userPublic, forDocument: publicRef)
				
				// Set values for user's private profile
				let privateRef = db.collection("users/\(userId)/private").document("userData")
				try batch.setData(from: userPrivate, forDocument: privateRef)
				
				// Commit the batch
				batch.commit() { error in
					if let error = error {
						print("Error writing batch: \(error.localizedDescription)")
					} else {
						print("Batch write succeeded")
					}
				}
				displayNextButton()
			} catch let error {
				print("Error writing data to the database: \(error.localizedDescription)")
				displayRetryButton()
			}
		}
	}
	
	@IBAction func nextButtonPressed(_ sender: UIButton){
		let vc = TabBarController()
		let keywindow = UIApplication.shared.windows.first {$0.isKeyWindow}
		keywindow?.rootViewController = vc
	}
	
	@IBAction func retryButtonPressed(_ sender: UIButton){
		sendResults()
	}
	
	func animateInQ() {
		UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveLinear, animations: {
			self.quizLabel.alpha = 1
			self.titleLabel.alpha = 1
		}, completion: nil)
	}
	
	func animateOutQ() {
		UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
			self.quizLabel.alpha = 0
			self.titleLabel.alpha = 0
		}, completion: nil)
	}
	func updateProgressBar (_ movement: Int = 1) {
		UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
			self.quizProgress.setProgress(self.quiz.getProgress(movement), animated: true)
		}, completion: nil)
	}
	
	func displayRetryButton() {
		let retryButton = UIButton(type: .custom)
		self.view.addSubview(retryButton)
		retryButton.alpha = 0
		retryButton.setTitle("Retry", for: .normal)
		retryButton.setTitleColor(UIColor.white, for: .normal)
		retryButton.translatesAutoresizingMaskIntoConstraints = false
		retryButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
		retryButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
		retryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 40).isActive = true
		retryButton.addTarget(self, action: #selector(retryButtonPressed(_:)), for: .touchUpInside)
		animateIn(retryButton, delay: 0)
	}
	
}

