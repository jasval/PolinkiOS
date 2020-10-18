//
//  MainOnboardViewController.swift
//  Polink
//
//  Created by Josh Valdivia on 21/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class MainOnboardViewController: UIViewController {
	private var delegate: MainOnboardViewControllerDelegate?
	private var itemsToDisplay = [
		OnboardingItemInfo(informationImage: UIImage(named: "hero-hello")!,
						   title: "Hello. Welcome to Polink!",
						   description: """
							You have already completed the registration process and must be eager to jump in some insightful conversations.
							To continue please swipe this page away.
							""",
						   pageIcon: UIImage(named: "hero-hello")!,
						   color: .white,
						   titleColor: .black,
						   descriptionColor: .black,
						   titleFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
						   descriptionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
						   descriptionLabelPadding: 20,
						   titleLabelPadding: 20),
		OnboardingItemInfo(informationImage: UIImage(named: "hero-search")!,
						   title: "Match with your opposites",
						   description: """
							Thanks to the information that you gave us we are able to match you with someone that will give you a good debate and a different perspective on key topics.
							Once that big match button is pressed our servers will open a chat room in your lobby for both parties.
							""",
						   pageIcon: UIImage(named: "hero-search")!,
						   color: .white,
						   titleColor: .black,
						   descriptionColor: .black,
						   titleFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
						   descriptionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
						   descriptionLabelPadding: 20,
						   titleLabelPadding: 20),
		OnboardingItemInfo(informationImage: UIImage(named: "hero-chat")!,
						   title: "Let's get a conversation going!",
						   description: """
							When you log into your room you will see the main chat view a toolbar with two buttons and a textbox.
							Those buttons are:
							1) To terminate the conversation and offer feedback.
							2) To suggest a new topic of conversation out of a collection of daily news we gathered for you.
							Aditionally, if you look to the top-right corner you will see a friendly officer that can help you report anti-social behaviour.
							""",
						   pageIcon: UIImage(named: "hero-chat")!,
						   color: .white,
						   titleColor: .black,
						   descriptionColor: .black,
						   titleFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
						   descriptionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
						   descriptionLabelPadding: 20,
						   titleLabelPadding: 20),
		OnboardingItemInfo(informationImage: UIImage(named: "hero-handshake")!,
						   title: "Ending a conversation",
						   description: """
							When ending a conversation, we provide a feedback form to evaluate the conversation through sliders and text-boxes.
							Your feedback is important for us to offer you accurate results and the best possible experience, it influences your metrics and the other person's.
							""",
						   pageIcon: UIImage(named: "hero-handshake")!,
						   color: .white,
						   titleColor: .black,
						   descriptionColor: .black,
						   titleFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
						   descriptionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
						   descriptionLabelPadding: 20,
						   titleLabelPadding: 20),
		OnboardingItemInfo(informationImage: UIImage(named: "hero-pie-stats")!,
						   title: "Conformity - Moral Humility",
						   description: """
							Big words! No worries we will break down the concept of those two metrics that appear in your homepage.
							Conformity measures how many matches that ended up in agreements you have had, it is desirable to have a conformity level that is not too high neither too low, like all humans we agree with some and disagree with others.
							Moral Humility measures how much appreciation or value you have given each disagreement, there is no correct or desirable range for this metric. Look at it as a nice way to get to know yourself a bit better.
							""",
						   pageIcon: UIImage(named: "hero-pie-stats")!,
						   color: .white,
						   titleColor: .black,
						   descriptionColor: .black,
						   titleFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
						   descriptionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
						   descriptionLabelPadding: 20,
						   titleLabelPadding: 20),
		OnboardingItemInfo(informationImage: UIImage(named: "hero-stats")!,
						   title: "Settings & Statistics",
						   description: """
							Ok, we promise this is the last screen and then we will leave you to it.
							We just wanted to tell you that detailed statistics can be found in your profile, as well as a switch to toggle visibility to be matched and a logout button.
							Ok, thats all. Polink away!
							""",
						   pageIcon: UIImage(named: "hero-stats")!,
						   color: .white,
						   titleColor: .black,
						   descriptionColor: .black,
						   titleFont: UIFont.systemFont(ofSize: 20, weight: .semibold),
						   descriptionFont: UIFont.systemFont(ofSize: 16, weight: .regular),
						   descriptionLabelPadding: 20,
						   titleLabelPadding: 20),
	]
	
	private lazy var skipButton: UIButton = {
		var button = UIButton(frame: CGRect(0, 0, 100, 100))
		button.setTitle("Skip >", for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		button.titleLabel?.textColor = .black
		button.tintColor = .black
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
		button.isHidden = true
		return button
	}()
	
	private lazy var doneButton: UIButton = {
		var button = UIButton(frame: CGRect(0, 0, 100, 100))
		button.setTitle("Done", for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		button.titleLabel?.textColor = .black
		button.tintColor = .black
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
		button.isHidden = true
		return button
	}()

	
	private lazy var onboardingView: PaperOnboarding = {
		let ob = PaperOnboarding()
		ob.backgroundColor = .systemPink
		ob.dataSource = self
		ob.delegate = self
		ob.translatesAutoresizingMaskIntoConstraints = false
		return ob
	}()
	
	init(delegate: MainOnboardViewControllerDelegate) {
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func skipButtonTapped(_ sender: UIButton) {
		onboardingWillTransitonToLeaving()
	}
	
	@objc func doneButtonTapped(_ sender: UIButton) {
		onboardingWillTransitonToLeaving()
	}
	
	override func viewDidLoad() {
		setupViews()
		
	}
	
	func setupViews() {
		
		view.addSubview(onboardingView)
		
		onboardingView.addSubview(skipButton)
		onboardingView.addSubview(doneButton)
				
		// add constraints
		for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
			let constraint = NSLayoutConstraint(item: onboardingView,
												attribute: attribute,
												relatedBy: .equal,
												toItem: view,
												attribute: attribute,
												multiplier: 1,
												constant: 0)
			view.addConstraint(constraint)
		}
		
		NSLayoutConstraint.activate([
			skipButton.topAnchor.constraint(equalTo: onboardingView.topAnchor, constant: 50),
			skipButton.rightAnchor.constraint(equalTo: onboardingView.rightAnchor, constant: -15),
			skipButton.heightAnchor.constraint(equalToConstant: 50),
			skipButton.widthAnchor.constraint(equalToConstant: 80),
			doneButton.topAnchor.constraint(equalTo: onboardingView.topAnchor, constant: 50),
			doneButton.rightAnchor.constraint(equalTo: onboardingView.rightAnchor, constant: -15),
			doneButton.heightAnchor.constraint(equalToConstant: 50),
			doneButton.widthAnchor.constraint(equalToConstant: 80)
		])
	}
	
}

extension MainOnboardViewController: PaperOnboardingDataSource {
	
	func onboardingItemsCount() -> Int {
		itemsToDisplay.count
	}
	
	func onboardingItem(at index: Int) -> OnboardingItemInfo {
		itemsToDisplay[index]
	}

	
}

extension MainOnboardViewController: PaperOnboardingDelegate {
	
	func onboardingWillTransitonToIndex(_ index: Int) {
		skipButton.isHidden = (index > 0 && index < itemsToDisplay.underestimatedCount-1 ? false : true)
		doneButton.isHidden = (index == itemsToDisplay.underestimatedCount-1 ? false : true)
	}
	
	func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index _: Int) {
		item.informationImageHeightConstraint?.constant = 150
		item.informationImageWidthConstraint?.constant = 150
	}
	
	func onboardingPageItemColor(at index: Int) -> UIColor {
		.black
	}
	
	func onboardingPageItemSelectedRadius() -> CGFloat {
		22
	}
	func onboardinPageItemRadius() -> CGFloat {
		8
	}
	
	func onboardingWillTransitonToLeaving() {
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(ConfigurationObject(name: "onboarded", value: true), update: .all)
			}
			self.navigationController?.fadeFrom()
		} catch {
			fatalError("Couldn't open realm")
		}
	}

}

protocol MainOnboardViewControllerDelegate {
	//
}
