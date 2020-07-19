//
//  ProfilerSliderView.swift
//  test
//
//  Created by Josh Valdivia on 17/07/2020.
//
//	 Icons used in this page can be found in 
//
//  Copyright © 2020 Return Generics. All rights reserved.
//

import UIKit

class ProfilerSliderView: UIView {
	
	private let title: String
	private var rangeMin: Float = 0
	private var rangeMax: Float = 100
	private lazy var midPoint: Float = rangeMax / 2
	private var step: Float {1}
	var governmentValue: Float?
	var societyValue: Float?
	var economyValue: Float?
	var diplomacyValue: Float?
	var delegate: FeedbackViewControllerDelegate?
	
	init(title: String, delegate: FeedbackViewControllerDelegate) {
		self.title = title
		self.delegate = delegate
		super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		setupViews()
		setupConstraints()
	}
	
	override init(frame: CGRect) {
		self.title = "Default Title"
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
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .natural
		label.textColor = .black
		return label
	}()

	let governmentLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = Feedback.governmentValue.rawValue
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()
	
	let sliderGovernment: UISlider = {
		let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.isContinuous = false
		slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
		slider.minimumValueImage = UIImage(named: "law")
		slider.maximumValueImage = UIImage(named: "liberty")
		slider.minimumTrackTintColor = #colorLiteral(red: 0.9448395371, green: 0.7668023109, blue: 0.06208644062, alpha: 1)
		slider.maximumTrackTintColor = #colorLiteral(red: 0.05947696418, green: 0.2518053651, blue: 0.7948236465, alpha: 1)
		return slider
	}()
	
	let societyLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = Feedback.societyValue.rawValue
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()

	let sliderSociety: UISlider = {
		let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.isContinuous = false
		slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
		slider.minimumValueImage = UIImage(named: "hourglass")
		slider.maximumValueImage = UIImage(named: "atom")
		slider.minimumTrackTintColor = #colorLiteral(red: 0.6085045338, green: 0.3478948474, blue: 0.7143780589, alpha: 1)
		slider.maximumTrackTintColor = #colorLiteral(red: 0.5465090275, green: 0.7590313554, blue: 0.2931880653, alpha: 1)
		return slider
	}()
	
	let economyLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = Feedback.economicValue.rawValue
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()

	let sliderEconomy: UISlider = {
		let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.isContinuous = false
		slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
		slider.minimumValueImage = UIImage(named: "dollar")
		slider.maximumValueImage = UIImage(named: "scales")
		slider.minimumTrackTintColor = #colorLiteral(red: 0.9062457085, green: 0.2975769639, blue: 0.2336881161, alpha: 1)
		slider.maximumTrackTintColor = #colorLiteral(red: 0.00341394986, green: 0.6289030313, blue: 0.1772145927, alpha: 1)
		return slider
	}()
	
	let diplomacyLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = Feedback.diplomacyValue.rawValue
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()

	let sliderDiplomacy: UISlider = {
		let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.isContinuous = false
		slider.addTarget(self, action: #selector(sliderValueDidChange(_:)), for: .valueChanged)
		slider.minimumValueImage = UIImage(named: "flag")
		slider.maximumValueImage = UIImage(named: "global")
		slider.minimumTrackTintColor = #colorLiteral(red: 0.204403311, green: 0.5952064395, blue: 0.857075572, alpha: 1)
		slider.maximumTrackTintColor = #colorLiteral(red: 0.9002369046, green: 0.4924015999, blue: 0.1369118989, alpha: 1)
		return slider
	}()

	
	func setupViews() {
		translatesAutoresizingMaskIntoConstraints = false
		self.layer.cornerRadius = 25
		self.layer.borderWidth  = 1
		self.layer.borderColor = UIColor.lightGray.cgColor
		self.addSubview(contentView)
		titleLabel.text = title
		titleLabel.numberOfLines = -1
		contentView.addArrangedSubview(titleLabel)
		contentView.addArrangedSubview(governmentLabel)
		contentView.addArrangedSubview(sliderGovernment)
		contentView.addArrangedSubview(societyLabel)
		contentView.addArrangedSubview(sliderSociety)
		contentView.addArrangedSubview(economyLabel)
		contentView.addArrangedSubview(sliderEconomy)
		contentView.addArrangedSubview(diplomacyLabel)
		contentView.addArrangedSubview(sliderDiplomacy)
		sliderGovernment.maximumValue = rangeMax
		sliderGovernment.minimumValue = rangeMin
		sliderGovernment.value = midPoint
		sliderSociety.maximumValue = rangeMax
		sliderSociety.minimumValue = rangeMin
		sliderSociety.value = midPoint
		sliderDiplomacy.maximumValue = rangeMax
		sliderDiplomacy.minimumValue = rangeMin
		sliderDiplomacy.value = midPoint
		sliderEconomy.minimumValue = rangeMin
		sliderEconomy.maximumValue = rangeMax
		sliderEconomy.value = midPoint
		
		//		contentView.addSubview(slider)
	}
	func setupConstraints() {
		
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
			contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
			contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
			contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
			
			titleLabel.heightAnchor.constraint(equalToConstant: 90),
			governmentLabel.heightAnchor.constraint(equalToConstant: 60),
			societyLabel.heightAnchor.constraint(equalTo: governmentLabel.heightAnchor),
			economyLabel.heightAnchor.constraint(equalTo: governmentLabel.heightAnchor),
			diplomacyLabel.heightAnchor.constraint(equalTo: governmentLabel.heightAnchor),
			
			sliderGovernment.heightAnchor.constraint(equalToConstant: 100),
			sliderSociety.heightAnchor.constraint(equalTo: sliderGovernment.heightAnchor),
			sliderEconomy.heightAnchor.constraint(equalTo: sliderGovernment.heightAnchor),
			sliderDiplomacy.heightAnchor.constraint(equalTo: sliderGovernment.heightAnchor),

		])
	}
	
	
	@objc func sliderValueDidChange (_ sender: UISlider!) {
		print("Slider value changed")
		
//		let roundedStepValue = round(sender.value / step) * step
//		sender.value = roundedStepValue
		
		switch sender {
		case sliderGovernment:
			governmentValue = sender.value
			delegate?.passSliderAnswerToViewController(numericFeedback: governmentValue!, feedbackType: .governmentValue)
		case sliderEconomy:
			economyValue = sender.value
			delegate?.passSliderAnswerToViewController(numericFeedback: economyValue!, feedbackType: .economicValue)
		case sliderDiplomacy:
			diplomacyValue = sender.value
			delegate?.passSliderAnswerToViewController(numericFeedback: diplomacyValue!, feedbackType: .diplomacyValue)
		case sliderSociety:
			societyValue = sender.value
			delegate?.passSliderAnswerToViewController(numericFeedback: societyValue!, feedbackType: .societyValue)
		default:
			return
		}
		
	}
	
	func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
		
		let size = image.size
		
		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height
		
		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		} else {
			newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
		}
		
		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
		
	}
}
