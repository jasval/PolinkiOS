//
//  CheckboxFeedbackView.swift
//  Polink
//
//  Created by Josh Valdivia on 26/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

import UIKit

class CheckboxFeedbackView: UIView {
	
	private let title: String
	var delegate: InputControllerDelegate?
	var type: Feedback = .agreement
	
	init(_ title: String, delegate: InputControllerDelegate) {
		self.type = .agreement
		self.title = title
		self.delegate = delegate
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		setupViews()
		setupConstraints()
	}
	
	override init(frame: CGRect) {
		self.title = "Default Title"
		self.type = Feedback.agreement
		super.init(frame: frame)
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let contentView: UIStackView = {
		let view = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.borderWidth = 1.0
		view.layer.cornerRadius = 25
		view.layer.borderColor = UIColor.lightGray.cgColor
		view.alignment = .fill
		view.axis = .vertical
		return view
	}()
	
	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .natural
		label.textColor = .black
		return label
	}()
	
	var checkBoxStack: UIStackView = {
		let stack = UIStackView(frame: CGRect(0, 0, 100, 100))
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.alignment = .center
		stack.distribution = .fill
		return stack
	}()
	
	lazy var optionNo: Checkbox = {
		let cb1 = Checkbox(frame: CGRect(0, 0, 40, 40))
		cb1.translatesAutoresizingMaskIntoConstraints = false
		cb1.checkmarkStyle = .tick
		cb1.borderStyle = .square
		cb1.borderCornerRadius = 7
		cb1.uncheckedBorderColor = .lightGray
		cb1.checkmarkColor = .black
		cb1.checkedBorderColor = .black
		return cb1
	}()
	
	lazy var optionYes: Checkbox = {
		let cb1 = Checkbox(frame: CGRect(0, 0, 40, 40))
		cb1.translatesAutoresizingMaskIntoConstraints = false
		cb1.checkmarkStyle = .tick
		cb1.borderStyle = .square
		cb1.borderCornerRadius = 7
		cb1.uncheckedBorderColor = .lightGray
		cb1.checkmarkColor = .black
		cb1.checkedBorderColor = .black
		return cb1
	}()
	
	var labelYes: UILabel = {
		let label = UILabel(frame: CGRect(0, 0, 100, 100))
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Yes"
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()
	
	var labelNo: UILabel = {
		let label = UILabel(frame: CGRect(0, 0, 100, 100))
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "No"
		label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()
	
	var contentViewNo: UIView?
	var contentViewYes: UIView?
	
	func setupViews() {
		translatesAutoresizingMaskIntoConstraints = false
		self.layer.cornerRadius = 25
		self.layer.borderWidth  = 1
		self.layer.borderColor = UIColor.lightGray.cgColor
		self.addSubview(contentView)
		textLabel.text = title
		textLabel.numberOfLines = -1
		contentView.addSubview(textLabel)
		contentView.addSubview(checkBoxStack)
		contentViewNo = UIView(frame: CGRect(0, 0, 100, 100))
		contentViewYes = UIView(frame: CGRect(0, 0, 100, 100))
		guard let viewYes = contentViewYes, let viewNo = contentViewNo else {return}
		viewNo.translatesAutoresizingMaskIntoConstraints = false
		viewYes.translatesAutoresizingMaskIntoConstraints = false
		viewNo.addSubview(labelNo)
		viewNo.addSubview(optionNo)
		viewYes.addSubview(labelYes)
		viewYes.addSubview(optionYes)
		
		checkBoxStack.addArrangedSubview(viewNo)
		checkBoxStack.addArrangedSubview(viewYes)

		optionNo.addTarget(self, action: #selector(didCheckNo(_:)), for: .valueChanged)
		optionYes.addTarget(self, action: #selector(didCheckYes(_:)), for: .valueChanged)

	}
	func setupConstraints() {
		guard let viewYes = contentViewYes, let viewNo = contentViewNo else {return}
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: self.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			
			textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			textLabel.heightAnchor.constraint(equalToConstant: 60),
			
			checkBoxStack.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
			checkBoxStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			checkBoxStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			checkBoxStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			viewNo.topAnchor.constraint(equalTo: checkBoxStack.topAnchor),
			viewNo.bottomAnchor.constraint(equalTo: checkBoxStack.bottomAnchor),
			viewNo.widthAnchor.constraint(equalTo: checkBoxStack.widthAnchor, multiplier: 0.5),
			viewNo.leadingAnchor.constraint(equalTo: checkBoxStack.leadingAnchor),
			viewYes.topAnchor.constraint(equalTo: checkBoxStack.topAnchor),
			viewYes.bottomAnchor.constraint(equalTo: checkBoxStack.bottomAnchor),
			viewYes.widthAnchor.constraint(equalTo: checkBoxStack.widthAnchor, multiplier: 0.5),
			viewYes.trailingAnchor.constraint(equalTo: checkBoxStack.trailingAnchor),
			
			optionNo.heightAnchor.constraint(equalToConstant: 40),
			optionNo.widthAnchor.constraint(equalToConstant: 40),
			optionNo.centerXAnchor.constraint(equalTo: viewNo.centerXAnchor),
			optionNo.centerYAnchor.constraint(equalTo: viewNo.centerYAnchor, constant: 10),
			labelNo.heightAnchor.constraint(equalToConstant: 30),
			labelNo.bottomAnchor.constraint(equalTo: optionNo.topAnchor),
			labelNo.centerXAnchor.constraint(equalTo: optionNo.centerXAnchor),
			
			
			optionYes.heightAnchor.constraint(equalToConstant: 40),
			optionYes.widthAnchor.constraint(equalToConstant: 40),
			optionYes.centerXAnchor.constraint(equalTo: viewYes.centerXAnchor),
			optionYes.centerYAnchor.constraint(equalTo: viewYes.centerYAnchor, constant: 10),
			labelYes.heightAnchor.constraint(equalToConstant: 30),
			labelYes.bottomAnchor.constraint(equalTo: optionYes.topAnchor),
			labelYes.centerXAnchor.constraint(equalTo: optionYes.centerXAnchor),
		])
	}
	
	@objc func didCheckNo(_ sender: Checkbox) {
		print("pressed no")
		optionYes.isChecked = false
		optionNo.isChecked = true
		
		delegate?.passBooleanAnswerToViewController(booleanAnswer: false, feedbackType: .agreement)
	}
	@objc func didCheckYes(_ sender: Checkbox) {
		print("pressed yes")
		optionNo.isChecked = false
		optionYes.isChecked = true
		delegate?.passBooleanAnswerToViewController(booleanAnswer: true, feedbackType: .agreement)
	}

}
