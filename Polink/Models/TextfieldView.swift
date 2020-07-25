//
//  TextfieldView.swift
//  test
//
//  Created by Josh Valdivia on 17/07/2020.
//  Copyright © 2020 Return Generics. All rights reserved.
//

import Foundation
import UIKit

class TextfieldView: UIView {
	
	private let title: String
	private var type: Feedback
	private var delegate: InputControllerDelegate?
	
	// Computed properties
	
	private var label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .natural
		label.textColor = .black
		label.numberOfLines = -1
		label.text = ""
		return label
	}()
	
	private var button: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Save", for: .normal)
		button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		button.titleLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		button.layer.cornerRadius = 25
		button.addTarget(self, action: #selector(userDidTapButton) , for: .touchUpInside)
		return button
	}()

	private var textView: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isEditable = true
		textView.autocapitalizationType = .sentences
		textView.isSelectable = true
		textView.layer.cornerRadius = 25
		textView.layer.borderWidth = 1
		textView.layer.borderColor = UIColor.lightGray.cgColor
		textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		textView.font = UIFont.systemFont(ofSize: 16)
		textView.text = "Please type your answer here..."
		textView.textColor = UIColor.lightGray
		return textView
	}()
	

	init(_ type: Feedback, title: String, delegate: InputControllerDelegate) {
		self.type = type
		self.title = title
		self.delegate = delegate
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		self.translatesAutoresizingMaskIntoConstraints = false
		setupViews()
		constraintViews()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews() {
		layer.borderWidth = 1
		layer.borderColor = UIColor.lightGray.cgColor
		layer.cornerRadius = 25
		textView.delegate = self
		label.text = title
		addSubview(textView)
		addSubview(button)
		addSubview(label)
		addDoneButtonOnKeyboard()
		let tap = UITapGestureRecognizer(target: self, action: #selector(textView.endEditing(_:)))
		addGestureRecognizer(tap)
	}
	
	func constraintViews() {
		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
			label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
			label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
			label.heightAnchor.constraint(equalToConstant: 60),
			
			textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
			textView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
			textView.trailingAnchor.constraint(equalTo: label.trailingAnchor),
			textView.heightAnchor.constraint(equalToConstant: 150),
			textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -10),
						
			button.topAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 1),
			button.heightAnchor.constraint(equalToConstant: 60),
			button.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
			button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
		])
	}
		
	@objc func userDidTapButton() {
		if isTextInViewLongEnough() {
			textView.layer.borderColor = UIColor.green.cgColor
			// Add animation
			delegate?.passTextfieldAnswerToViewController(textAnswer: textView.text, feedbackType: type)
			textView.endEditing(true)
		} else {
			// Add shaking animation
			textView.layer.borderColor = UIColor.red.cgColor
			// Add Popup alert
		}
	}
	
}

extension TextfieldView: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
		textView.becomeFirstResponder()
	}
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "Please type your answer here..."
			textView.textColor = UIColor.lightGray
		}
		textView.resignFirstResponder()
	}
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		textView.resignFirstResponder()
		return true
	}
	
	func isTextInViewLongEnough() -> Bool {
		return textView.text.count > 50
	}
	
	func addDoneButtonOnKeyboard() {
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		doneToolbar.barStyle = .default
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
		
		let items = [flexSpace, done]
		doneToolbar.items = items
		doneToolbar.sizeToFit()
		
		textView.inputAccessoryView = doneToolbar
	}
	
	@objc func doneButtonAction() {
		textView.resignFirstResponder()
	}
}
