//
//  FeedbackVC.swift
//  Polink
//
//  Created by Josh Valdivia on 14/07/2020.
//  Copyright © 2020 Return Generics. All rights reserved.
//

import UIKit

public enum Feedback: String {
	case conversationRating = "How would you rate the conversation?"
	case engagementRating = "How engaging was the conversation?"
	case informativeRating = "How informative was the conversation?"
	case interlocutorIdeas = "Summarise the other person's ideas."
	case agreedOn = "What did you agree on?"
	case learnings = "What did you learn from this conversation?"
	case finalRebuttal = "Offer your closing arguments."
	case governmentValue = "Libertarian or Authoritorian?"
	case economicValue = "Equality or Growth in Economy?"
	case diplomacyValue = "Nation-centric or Globalised?"
	case societyValue = "Traditionalist or Progressive?"
	case agreement = "Did you agree in any topics?"
}

protocol InputControllerDelegate {
	func passSliderAnswerToViewController(numericFeedback: Int, feedbackType: Feedback)
	func passTextfieldAnswerToViewController(textAnswer: String?, feedbackType: Feedback)
	func passSliderAnswerToViewController(numericFeedback: Double, feedbackType: Feedback)
	func passBooleanAnswerToViewController(booleanAnswer: Bool, feedbackType: Feedback)
}

protocol FeedbackViewControllerDelegate {
	func sendFeedback(newFeedback: ParticipantFeedback)
}

class FeedbackVC: UIViewController {
	
	private enum Headers: String {
		case conversation = "About the conversation..."
		case interlocutor = "About the other person..."
		case learnings = "About their ideas..."
		case finalRemarks = "Any last ideas on your mind?"
	}
	
	init(_ feedbacks: ParticipantFeedback, delegate: FeedbackViewControllerDelegate ) {
		self.delegate = delegate
		self.feedback = feedbacks
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)

		setupViews()
		setupConstraints()
	}
	
	private var scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.translatesAutoresizingMaskIntoConstraints = false
		return scroll
	}()
	
	private var headerConversation: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .boldSystemFont(ofSize: 19)
		label.text = Headers.conversation.rawValue
		return label
	}()
	
	private var headerInterlocutor: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .boldSystemFont(ofSize: 19)
		label.text = Headers.interlocutor.rawValue
		return label
	}()

	private var headerLearnings: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .boldSystemFont(ofSize: 19)
		label.text = Headers.learnings.rawValue
		return label
	}()
	
	private var headerFinalRemarks: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .boldSystemFont(ofSize: 19)
		label.text = Headers.finalRemarks.rawValue
		return label
	}()

	private var button: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Record Feedback", for: .normal)
		button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		button.titleLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		button.layer.cornerRadius = 25
		button.addTarget(self, action: #selector(userDidPressFeedbackButton), for: .touchUpInside)
		return button
	}()

	private var feedbackForm: [Feedback:Any] = [:]

	private var feedback: ParticipantFeedback
	private var delegate: FeedbackViewControllerDelegate
	private var agreementView: CheckboxFeedbackView?
	private var conversationRatingSlider: SliderView?
	private var engagementRatingSlider: SliderView?
	private var informativeRatingSlider: SliderView?
	private var profilerSlider: ProfilerSliderView?
	private var agreedOnTextView: TextfieldView?
	private var learningsTexView: TextfieldView?
	private var interlocutorIdeasTextView: TextfieldView?
	private var finalRebuttalTextView: TextfieldView?
	
	let step: Float = 10
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

	@objc func sliderValueDidChange (_ sender: UISlider!) {
		print("Slider value changed")

		let roundedStepValue = round(sender.value / step) * step
		sender.value = roundedStepValue

		print("Slider step value \(Int(roundedStepValue))")
	}

	// MARK: - Setup
	func setupViews() {
		
		view.addSubview(scrollView)
		scrollView.backgroundColor = .white
		
		scrollView.addSubview(headerConversation)
		
		agreementView = CheckboxFeedbackView(Feedback.agreement.rawValue, delegate: self)
		scrollView.addSubview(agreementView!)
				
		conversationRatingSlider = SliderView(.conversationRating, title: Feedback.conversationRating.rawValue, rangeMin: 0, rangeMax: 5, step: 1, delegate: self)
		scrollView.addSubview(conversationRatingSlider!)
		
		engagementRatingSlider = SliderView(.engagementRating, title: Feedback.engagementRating.rawValue, rangeMin: 0, rangeMax: 5, step: 1, delegate: self)
		scrollView.addSubview(engagementRatingSlider!)
		
		informativeRatingSlider = SliderView(.informativeRating, title: Feedback.informativeRating.rawValue, rangeMin: 0, rangeMax: 5, step: 1, delegate: self)
		scrollView.addSubview(informativeRatingSlider!)
		
		scrollView.addSubview(headerInterlocutor)
		
		profilerSlider = ProfilerSliderView(title: "What is your perceived notion of the other speaker?", delegate: self)
		scrollView.addSubview(profilerSlider!)
		
		
		scrollView.addSubview(headerLearnings)
		
		agreedOnTextView = TextfieldView(.agreedOn, title: Feedback.agreedOn.rawValue, delegate: self)
		scrollView.addSubview(agreedOnTextView!)
		
		interlocutorIdeasTextView = TextfieldView(.interlocutorIdeas, title: Feedback.interlocutorIdeas.rawValue, delegate: self)
		scrollView.addSubview(interlocutorIdeasTextView!)
		
		learningsTexView = TextfieldView(.learnings, title: Feedback.learnings.rawValue, delegate: self)
		scrollView.addSubview(learningsTexView!)
		
		scrollView.addSubview(headerFinalRemarks)
		
		finalRebuttalTextView = TextfieldView(.finalRebuttal, title: Feedback.finalRebuttal.rawValue, delegate: self)
		scrollView.addSubview(finalRebuttalTextView!)
		
		scrollView.addSubview(button)
		
	}
	
	func setupConstraints() {
		guard let convo = conversationRatingSlider, let inf = informativeRatingSlider, let eng = engagementRatingSlider, let profiler = profilerSlider, let agr = agreedOnTextView, let inter = interlocutorIdeasTextView, let lear = learningsTexView, let freb = finalRebuttalTextView, let check = agreementView else {return}
		
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.contentLayoutGuide.heightAnchor.constraint(equalToConstant: 3000),
			scrollView.contentLayoutGuide.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
			scrollView.contentLayoutGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			scrollView.contentLayoutGuide.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			
			headerConversation.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
			headerConversation.heightAnchor.constraint(equalToConstant: 60),
			headerConversation.widthAnchor.constraint(equalToConstant: view.frame.width - 60),
			headerConversation.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			
			check.topAnchor.constraint(equalToSystemSpacingBelow: headerConversation.bottomAnchor, multiplier: 1.5),
			check.heightAnchor.constraint(equalToConstant: 150),
			check.widthAnchor.constraint(equalTo: headerConversation.widthAnchor),
			check.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

			convo.topAnchor.constraint(equalToSystemSpacingBelow: check.bottomAnchor, multiplier: 1.5),
			convo.heightAnchor.constraint(equalToConstant: 150),
			convo.widthAnchor.constraint(equalTo: check.widthAnchor),
			convo.centerXAnchor.constraint(equalTo: check.centerXAnchor),
			
			eng.topAnchor.constraint(equalToSystemSpacingBelow: convo.bottomAnchor, multiplier: 1.5),
			eng.heightAnchor.constraint(equalTo: convo.heightAnchor),
			eng.widthAnchor.constraint(equalTo: convo.widthAnchor),
			eng.centerXAnchor.constraint(equalTo: convo.centerXAnchor),
			
			inf.topAnchor.constraint(equalToSystemSpacingBelow: eng.bottomAnchor, multiplier: 1.5),
			inf.heightAnchor.constraint(equalTo: convo.heightAnchor),
			inf.widthAnchor.constraint(equalTo: convo.widthAnchor),
			inf.centerXAnchor.constraint(equalTo: convo.centerXAnchor),

			
			headerInterlocutor.topAnchor.constraint(equalToSystemSpacingBelow: inf.bottomAnchor, multiplier: 4),
			headerInterlocutor.widthAnchor.constraint(equalTo: headerConversation.widthAnchor),
			headerInterlocutor.heightAnchor.constraint(equalTo: headerConversation.heightAnchor),
			headerInterlocutor.centerXAnchor.constraint(equalTo: headerConversation.centerXAnchor),
			
			profiler.topAnchor.constraint(equalToSystemSpacingBelow: headerInterlocutor.bottomAnchor, multiplier: 1.5),
			profiler.widthAnchor.constraint(equalTo: convo.widthAnchor),
			profiler.centerXAnchor.constraint(equalTo: convo.centerXAnchor),
			
			headerLearnings.topAnchor.constraint(equalToSystemSpacingBelow: profiler.bottomAnchor, multiplier: 4),
			headerLearnings.widthAnchor.constraint(equalTo: headerConversation.widthAnchor),
			headerLearnings.heightAnchor.constraint(equalTo: headerConversation.heightAnchor),
			headerLearnings.centerXAnchor.constraint(equalTo: headerConversation.centerXAnchor),
			
			agr.topAnchor.constraint(equalToSystemSpacingBelow: headerLearnings.bottomAnchor, multiplier: 1.5),
			agr.widthAnchor.constraint(equalTo: convo.widthAnchor),
			agr.centerXAnchor.constraint(equalTo: convo.centerXAnchor),
			
			inter.topAnchor.constraint(equalToSystemSpacingBelow: agr.bottomAnchor, multiplier: 1.5),
			inter.widthAnchor.constraint(equalTo: convo.widthAnchor),
			inter.centerXAnchor.constraint(equalTo: convo.centerXAnchor),

			lear.topAnchor.constraint(equalToSystemSpacingBelow: inter.bottomAnchor, multiplier: 1.5),
			lear.widthAnchor.constraint(equalTo: agr.widthAnchor),
			lear.centerXAnchor.constraint(equalTo: convo.centerXAnchor),

			headerFinalRemarks.topAnchor.constraint(equalToSystemSpacingBelow: lear.bottomAnchor, multiplier: 4),
			headerFinalRemarks.widthAnchor.constraint(equalTo: headerConversation.widthAnchor),
			headerFinalRemarks.heightAnchor.constraint(equalTo: headerConversation.heightAnchor),
			headerFinalRemarks.centerXAnchor.constraint(equalTo: headerConversation.centerXAnchor),

			freb.topAnchor.constraint(equalToSystemSpacingBelow: headerFinalRemarks.bottomAnchor, multiplier: 1.5),
			freb.widthAnchor.constraint(equalTo: convo.widthAnchor),
			freb.centerXAnchor.constraint(equalTo: convo.centerXAnchor),
			
			button.topAnchor.constraint(equalToSystemSpacingBelow: freb.bottomAnchor, multiplier: 4),
			button.widthAnchor.constraint(equalTo: convo.widthAnchor),
			button.heightAnchor.constraint(equalToConstant: 60),
			button.centerXAnchor.constraint(equalTo: convo.centerXAnchor)
		])
	}

	@objc func keyboardWillShow(notification:NSNotification){
		
		let userInfo = notification.userInfo!
		var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)
		
		var contentInset:UIEdgeInsets = self.scrollView.contentInset
		contentInset.bottom = keyboardFrame.size.height + 20
		scrollView.contentInset = contentInset
	}
	
	@objc func keyboardWillHide(notification:NSNotification){
		
		let contentInset:UIEdgeInsets = UIEdgeInsets.zero
		scrollView.contentInset = contentInset
	}
	
	@objc func userDidPressFeedbackButton () {
		// Use logic to check if fields are completed or not...
		if checkCompleteness() {
			print("form is complete")
			// Dismiss current view controller and copy the information to another collection in database
			feedback.agreedOn = feedbackForm[.agreedOn] as! String
			feedback.agreement = feedbackForm[.agreement] as! Bool
			feedback.conversationRating = feedbackForm[.conversationRating] as! Int
			feedback.engagementRating = feedbackForm[.engagementRating] as! Int
			feedback.finalRebuttal = feedbackForm[.finalRebuttal] as! String
			feedback.informativeRating = feedbackForm[.informativeRating] as! Int
			feedback.interlocutorIdeas = feedbackForm[.interlocutorIdeas] as! String
			feedback.learnings = feedbackForm[.learnings] as! String
			feedback.perceivedIdeology.dipl = feedbackForm[.diplomacyValue] as! Double
			feedback.perceivedIdeology.econ = feedbackForm[.economicValue] as! Double
			feedback.perceivedIdeology.govt = feedbackForm[.governmentValue] as! Double
			feedback.perceivedIdeology.scty = feedbackForm[.societyValue] as! Double
			
			delegate.sendFeedback(newFeedback: feedback)
			
		} else {
			// Animate shake button
			// Show alert
			let alert = UIAlertController(title: "Incomplete form", message: "Not all fields have been filled", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
		}
	}

	func checkCompleteness() -> Bool {
		
		if feedbackForm.count < 11 {
			return false
		}
		
		let result = feedbackForm.reduce(true) { (result, tupleKeyValue) -> Bool in
			if result && tupleKeyValue.value != nil {
				return true
			} else {
				return false
			}
		}
		return result
	}
}

extension FeedbackVC: InputControllerDelegate {
	func passBooleanAnswerToViewController(booleanAnswer: Bool, feedbackType: Feedback) {
		feedbackForm[feedbackType] = booleanAnswer
	}
	
	func passTextfieldAnswerToViewController(textAnswer: String?, feedbackType: Feedback) {
		guard let answer = textAnswer else {return}
		feedbackForm[feedbackType] = answer
	}
	
	func passSliderAnswerToViewController(numericFeedback: Int, feedbackType: Feedback) {
		feedbackForm[feedbackType] = numericFeedback
	}
	
	func passSliderAnswerToViewController(numericFeedback: Double, feedbackType: Feedback) {
		feedbackForm[feedbackType] = numericFeedback
	}

}
