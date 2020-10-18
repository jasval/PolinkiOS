//
//  SliderView.swift
//  test
//
//  Created by Josh Valdivia on 14/07/2020.
//  Copyright © 2020 Return Generics. All rights reserved.
//

import UIKit

class SliderView: UIView {

	private let title: String
	private let rangeMin: Float
	private let rangeMax: Float
	var currentValue: Double
	var delegate: InputControllerDelegate?
	var type: Feedback
	
	init(_ type: Feedback, title: String, rangeMin: Float, rangeMax: Float, step: Float, delegate: InputControllerDelegate) {
		self.type = type
		self.title = title
		self.rangeMin = rangeMin
		self.rangeMax = rangeMax
		self.currentValue = Double(rangeMin)
		self.delegate = delegate
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		setupViews()
		setupConstraints()
	}
	
	override init(frame: CGRect) {
		self.title = "Default Title"
		self.rangeMin = 0
		self.rangeMax = 5
		self.currentValue = 0
		self.type = Feedback.agreedOn
		super.init(frame: frame)
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	let headerView: UIStackView = {
		let horizontalStack = UIStackView()
		horizontalStack.translatesAutoresizingMaskIntoConstraints = false
		horizontalStack.axis = .horizontal
		horizontalStack.alignment = .fill
		horizontalStack.backgroundColor = .green
		return horizontalStack
	}()
	
	let textLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .natural
		label.adjustsFontForContentSizeCategory = true
		label.textColor = .black
		return label
	}()
	
	let answerLabel: UILabel = {
		let answer = UILabel()
		answer.translatesAutoresizingMaskIntoConstraints = false
		answer.textAlignment = .center
		answer.adjustsFontForContentSizeCategory = true
		answer.layer.borderColor = UIColor.lightGray.cgColor
		answer.layer.borderWidth = 1
		answer.layer.cornerRadius = 25
		return answer
	}()
	
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
	
	lazy var slider: UISlider = {
		let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.isContinuous = false
		return slider
	}()
	
	func setupViews() {
		translatesAutoresizingMaskIntoConstraints = false
		self.layer.cornerRadius = 25
		self.layer.borderWidth  = 1
		self.layer.borderColor = UIColor.lightGray.cgColor
		self.addSubview(contentView)
		textLabel.text = title
		textLabel.numberOfLines = -1
		contentView.addArrangedSubview(headerView)
		headerView.addArrangedSubview(textLabel)
		headerView.addArrangedSubview(answerLabel)
		slider.maximumValue = rangeMax
		slider.minimumValue = rangeMin
		slider.isUserInteractionEnabled = true
		contentView.addArrangedSubview(slider)
		slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
	}
	func setupConstraints() {
		
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: self.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			
			headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			headerView.heightAnchor.constraint(equalToConstant: 60),
			
			slider.topAnchor.constraint(equalTo: headerView.bottomAnchor),
			slider.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
			slider.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
			slider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			textLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
			textLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
			textLabel.trailingAnchor.constraint(equalTo: answerLabel.leadingAnchor),
			textLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
			
			answerLabel.topAnchor.constraint(equalTo: textLabel.topAnchor),
			answerLabel.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor),
			answerLabel.widthAnchor.constraint(equalToConstant: 60),
			answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
		])
	}
	

	@objc func sliderValueDidChange (_ sender: UISlider!) {
		print("Slider value changed")
		
		currentValue = Double(sender.value)
		DispatchQueue.main.async {
			self.answerLabel.text = String(format: "%.1f", self.currentValue)
		}
		
		delegate?.passSliderAnswerToViewController(numericFeedback: currentValue, feedbackType: type)
		
//		print("Slider step value \(Int(roundedStepValue))")
	}
}
