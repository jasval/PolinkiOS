//
//  PoliticalQuizVC.swift
//  Polink
//
//  Created by Josh Valdivia on 17/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import Charts
import RealmSwift
import FirebaseFirestore
import FirebaseAuth

class PoliticalQuizVC: UIViewController {
	
	private var titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Welcome back!"
		label.alpha = 0.0
		return label
	}()
	
	private var quizLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "We will ask you some more questions about your views, this should take around 10 min."
		label.alpha = 0.0
		return label
	}()
	
	private var quizProgressBar: UIProgressView = {
		let view = UIProgressView(progressViewStyle: .default)
		view.progressTintColor = .black
		view.trackTintColor = .systemGray6
		view.contentMode = .scaleToFill
		view.autoresizesSubviews = true
		view.progress = 0.0
		view.transform = view.transform.scaledBy(x: 1, y: 4)
		view.layer.masksToBounds = true
		view.layer.cornerRadius = 25
		view.alpha = 0.0
		return view
	}()
	
	private var answerStackView: UIStackView = {
		var buttons = [AnswerButton]()
		for i in 1...5 {
			let button = AnswerButton(position: i)
			button.addTarget(self, action: #selector(answerButtonPressed(_:)),
							 for: .touchUpInside)
			buttons.append(button)
		}
		let stack = UIStackView(arrangedSubviews: buttons)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.alignment = .fill
		stack.distribution = .fillEqually
		stack.spacing = 10.0
		stack.contentMode = .scaleToFill
		stack.axis = .vertical
		return stack
	}()
	
	private var backButton: UIButton = {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"),
						for: .normal)
		button.addTarget(self, action: #selector(backButtonPressed(_:)),
						 for: .touchUpInside)
		button.backgroundColor = .lightGray
		button.tintColor = .white
		button.contentMode = .scaleToFill
		button.contentVerticalAlignment = .center
		button.layer.masksToBounds = true
		button.layer.cornerRadius = 25
		button.alpha = 0.0
		return button
	}()
	
	
	private var results: RadarChartView?
	lazy var quiz = QuizBrain()
	private var delegate: PoliticalQuizVCDelegate?
	private lazy var previousQuestions = [Question]()
	private var previousIdeology: IdeologyMapping?
	private var newIdeology: IdeologyMapping?
	private lazy var db = Firestore.firestore()
	private var completionBlock: (() -> ())?
	
	init(questions: Results<QuestionObject>,
		 userIdeology: IdeologyMapping,
		 delegate: PoliticalQuizVCDelegate,
		 completion: (() -> ())? ) {
		self.completionBlock = completion
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
		
		for element in questions {
			let question = Question(managedObject: element)
			self.previousQuestions.append(question)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
		Timer.scheduledTimer(withTimeInterval: 9, repeats: false) { (Timer) in
			self.startQuiz()
		}
	}
	
	@objc func answerButtonPressed(_ sender: AnswerButton) {
		sender.pulsate()
		quiz.nextQuestion(sender.effect!)
		loadQuestion()
		updateProgressBar()
	}
	
	@objc func backButtonPressed(_ sender: UIButton) {
		sender.pulsate()
		quiz.prevQuestion()
		loadQuestion()
		updateProgressBar(-1)
	}

	@objc func nextButtonPressed(_ sender: UIButton) {
		sender.pulsate()
		completionBlock?()
	}
	
	@objc func retryButtonPressed(_ sender: UIButton) {
		sender.pulsate()
		sendResults()
	}
		
	func startQuiz() {
		quiz.initQuiz(with: previousQuestions)
		loadQuestion()
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
				animateOut(answerStackView)
				
				newIdeology = IdeologyMapping(econ: finalScore.econ,
											  dipl: finalScore.dipl,
											  scty: finalScore.scty,
											  govt: finalScore.scty)
				
				animateOut(quizProgressBar)
				displayResults()
				sendResults()
				writeQuestionsToDB(quiz.getQuestionStack())
			} catch {
				print(error)
			}
		}
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
			self.quizProgressBar.setProgress(self.quiz.getProgress(movement), animated: true)
		}, completion: nil)
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
		guard let newIdeology = newIdeology else {return}
		results = RadarChartView()
		results?.translatesAutoresizingMaskIntoConstraints = false
		results?.noDataText = "There is no data to display int the graph"
		let dataSet = GraphView.createRadarCharDataSet(data: newIdeology, name: "User Data")
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
			graph.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
									   constant: 100),
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
			nextButton.topAnchor.constraint(equalTo: view.centerYAnchor,
											constant: 150)
		])
		nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)),
							 for: .touchUpInside)
		animateIn(nextButton, delay: 5)
	}
	
	func displayRetryButton() {
		let retryButton = UIButton(type: .custom)
		retryButton.layer.cornerRadius = 10
		retryButton.backgroundColor = UIColor.gray
		retryButton.setTitle("Next", for: .normal)
		retryButton.setTitleColor(UIColor.white,
								  for: .normal)
		retryButton.alpha = 0
		retryButton.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(retryButton)
		NSLayoutConstraint.activate([
			retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			retryButton.heightAnchor.constraint(equalToConstant: 80),
			retryButton.widthAnchor.constraint(equalToConstant: 300),
			retryButton.topAnchor.constraint(equalTo: view.centerYAnchor,
											 constant: 150)
		])
		retryButton.addTarget(self, action: #selector(retryButtonPressed(_:)),
							  for: .touchUpInside)
		animateIn(retryButton, delay: 5)
	}
	
	func sendResults() {
		guard let userId = Auth.auth().currentUser?.uid, let newIdeology = newIdeology else {return}
		// Create a write batch
		let batch = db.batch()
		
		// Update ideology for target user
		let publicRef = db.collection("users").document(userId)
		batch.updateData(["ideology": newIdeology], forDocument: publicRef)
		
		// Commit the batch
		batch.commit() { [weak self] error in
			if let error = error {
				print("Error writing batch: \(error.localizedDescription)")
			} else {
				print("Batch write succeeded")
				self?.delegate?.politicalQuizViewController(didSave: self?.quiz.getQuestionStack() ?? [Question]())
			}
		}
		displayNextButton()
	}
}

protocol PoliticalQuizVCDelegate {
	func politicalQuizViewController(didSave questionObjects: [Question] )
}
