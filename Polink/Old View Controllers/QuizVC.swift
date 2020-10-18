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
import Charts
import RealmSwift

class QuizVC: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var quizProgress: UIProgressView!
	@IBOutlet var buttons: [UIButton]! = []
	@IBOutlet weak var quizLabel: UILabel!
	@IBOutlet weak var answerStack: UIStackView!
	@IBOutlet weak var backButton: UIButton!
	private var results : RadarChartView?
	// creating an instance of the QuizBrain
	lazy var quiz = QuizBrain()
	
	// initialising the firestore database
	let db = Firestore.firestore()
	
	//handler of the auth state listener
	var handle: AuthStateDidChangeListenerHandle?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// progress bar styling and initialisation
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
		\nThere are no right or wrong answers.
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
		sender.pulsate()
		quiz.nextQuestion(sender.effect!)
		loadQuestion()
		updateProgressBar()
	}
	
	@IBAction func backButtonPressed(_ sender: UIButton) {
		// Back Button
		sender.pulsate()
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
		if quiz.questionNo < quiz.questionStack!.count {
			quizLabel.text = quiz.questionStack?[quiz.questionNo].prompt
			titleLabel.text = "Question: \(quiz.questionNo + 1)"
			animateInQ()
		} else {
			do{
				let finalScore = try quiz.calcScores()
				// Printing and declaration of lastScore for testing
//				let lastScore = quiz.answerStack.peek()
				animateOut(backButton)
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
				writeQuestionsToDB(quiz.getQuestionStack())
			} catch {
				print(error)
			}
		}
	}
	
	func writeQuestionsToDB(_ questions: [Question]?) {
		guard let questions = questions else {return}
		
		do {
			let container = try Container(userID: Auth.auth().currentUser?.uid)
			try container.write({ (transaction) in
				for question in questions {
					transaction.add(question, update: .all)
				}
			})
		} catch {
			fatalError(error.localizedDescription)
		}

	}
	
	func displayResults(){
		let ideology = IdeologyMapping(econ: Registration.state.polinkIdeology?[K.ideologyAxes.econ] ?? 0,
									   dipl: Registration.state.polinkIdeology?[K.ideologyAxes.dipl] ?? 0,
									   scty: Registration.state.polinkIdeology?[K.ideologyAxes.scty] ?? 0,
									   govt: Registration.state.polinkIdeology?[K.ideologyAxes.govt] ?? 0)
		results = RadarChartView()
		results?.translatesAutoresizingMaskIntoConstraints = false
		results?.noDataText = "There is no data to display int the graph"
		let dataSet = GraphView.createRadarCharDataSet(data: ideology, name: "User Data")
		let redColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 1)
		let redFillColor = UIColor(red: 247/255, green: 67/255, blue: 115/255, alpha: 0.6)
		dataSet.colors = [redColor]
		dataSet.fillColor = redFillColor
		dataSet.drawFilledEnabled = true
		dataSet.valueFormatter = DataSetValueFormatter()
		let data = RadarChartData(dataSet: dataSet)

		results?.data = data
		results?.webLineWidth = 0.5
		results?.innerWebLineWidth = 0.5
		results?.webColor = .lightGray
		results?.innerWebColor = .lightGray
		results?.rotationEnabled = false
		results?.legend.enabled = false
		results?.isMultipleTouchEnabled = true
		results?.isUserInteractionEnabled = false

		let xAxis = results?.xAxis
		xAxis?.labelFont = .systemFont(ofSize: 10, weight: .bold)
		xAxis?.labelTextColor = .black
		xAxis?.xOffset = 10
		xAxis?.yOffset = 10
		xAxis?.valueFormatter = XAxisFormatter()
		
		let yAxis = results?.yAxis
		yAxis?.labelFont = .systemFont(ofSize: 9, weight: .light)
		yAxis?.labelCount = 3
		yAxis?.labelXOffset = 5
		yAxis?.drawTopYLabelEntryEnabled = true
		yAxis?.axisMinimum = 0
		yAxis?.valueFormatter = YAxisFormatter()

		guard let graph = results else { return }
		view.addSubview(graph)
		
		NSLayoutConstraint.activate([
			graph.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
			graph.heightAnchor.constraint(equalToConstant: 350),
			graph.widthAnchor.constraint(equalToConstant: 350),
			graph.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
		
		animateChart()
	}
	
	func animateChart() {
		results?.animate(yAxisDuration: 1.4, easingOption: .linear)
	}

	
	func displayNextButton() {
		let nextButton = UIButton(type: .roundedRect)
		nextButton.layer.cornerRadius = 10
		nextButton.backgroundColor = UIColor.gray
		nextButton.setTitle("Next", for: .normal)
		nextButton.setTitleColor(UIColor.white, for: .normal)
		nextButton.alpha = 0
		nextButton.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(nextButton)
		NSLayoutConstraint.activate([
			nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			nextButton.heightAnchor.constraint(equalToConstant: 80),
			nextButton.widthAnchor.constraint(equalToConstant: 300),
			nextButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 150)
		])
		nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
		animateIn(nextButton, delay: 5)
	}
	
	func displayRetryButton() {
		let retryButton = UIButton(type: .custom)
		retryButton.layer.cornerRadius = 10
		retryButton.backgroundColor = UIColor.gray
		retryButton.setTitle("Next", for: .normal)
		retryButton.setTitleColor(UIColor.white, for: .normal)
		retryButton.alpha = 0
		retryButton.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(retryButton)
		NSLayoutConstraint.activate([
			retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			retryButton.heightAnchor.constraint(equalToConstant: 80),
			retryButton.widthAnchor.constraint(equalToConstant: 300),
			retryButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 150)
		])
		retryButton.addTarget(self, action: #selector(retryButtonPressed(_:)), for: .touchUpInside)
		animateIn(retryButton, delay: 5)
	}
	
	func sendResults() {
		let userId = Auth.auth().currentUser?.uid
		let userEmail =  Auth.auth().currentUser?.email
		let r = Registration.state
		if let userId = userId, let userEmail = userEmail {
			let ideology = IdeologyMapping(econ: (r.polinkIdeology?[K.ideologyAxes.econ])!,
										   dipl: (r.polinkIdeology?[K.ideologyAxes.dipl])!,
										   scty: (r.polinkIdeology?[K.ideologyAxes.scty])!,
										   govt: (r.polinkIdeology?[K.ideologyAxes.govt])!)
			let userPublic = ProfilePublic(uid: userId,
										   country: r.geoLocCountry ?? "United Kingdom",
										   city: r.geoLocCity ?? "London",
										   ideology: ideology,
										   listening: true,
										   redFlags: 0,
										   fcm: "")
			let userPrivate = ProfilePrivate(email: userEmail,
											 firstName: r.fname!,
											 lastName: r.lname!,
											 gender: r.gender!,
											 createdAt: Date(),
											 dateOfBirth: r.dob!)
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
		sender.pulsate()
		let vc = TabBarController()
		let keywindow = UIApplication.shared.windows.first {$0.isKeyWindow}
		keywindow?.rootViewController = vc
	}
	
	@IBAction func retryButtonPressed(_ sender: UIButton){
		sender.pulsate()
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
}

