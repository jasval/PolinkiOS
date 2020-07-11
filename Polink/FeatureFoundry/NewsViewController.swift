//
//  NewsViewController.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class NewsViewController: OnboardViewController {
	
	override var buttons: [Button] {
		let doneButton = Button(title: "Got It!", style: .primary) { [unowned self] in
			
//			self.printCurrentValues()
			let currentView = self.newsToDisplay[self.currentPage]
			print(currentView.title)
			
			self.delegate.newsViewControllerDidFinish(self)
		}
		return [doneButton]
	}
	
//	func printCurrentValues() {
//
//	}
	
//	override var contentView: UIView?
	// It was UIView before
	override var contentView: OnboardPagingView {

		var viewsToDisplay = Array<UIView>()
		newsToDisplay.forEach { (news) in
			let imageURL = URL(string: news.imageURL ?? "")
			
			print(imageURL)
			let vc = contentViewWith(title: news.title, bodyText: news.description ?? "", imageURL: imageURL)
			viewsToDisplay.append(vc)
		}
		
		let pagingView = OnboardPagingView(pages: viewsToDisplay, delegate: self)

		return pagingView
	}
	
	var newsToDisplay: [News]
	var viewsToDisplay: [UIView]?
	let delegate: NewsViewControllerDelegate
	
	private var currentPage: Int = 0
	
	init(newsToDisplay: [News], delegate: NewsViewControllerDelegate) {
		self.delegate = delegate
		self.newsToDisplay = newsToDisplay
		self.viewsToDisplay = Array<UIView>()
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layoutEmphasis = .none
	}
	
	func contentViewWith(title: String, bodyText: String, imageURL: URL?) -> UIView {
		guard let url = imageURL else {
			let modalLayoutView = ModalLayoutView(title: title, body: bodyText, contentView: nil, buttons: [])
			return modalLayoutView
		}
		let imageView = NewsImageView(frame: .zero, url: url)
		imageView.sizeToFit()
		let modalLayoutView = ModalLayoutView(title: title,
														  body: bodyText,
														  contentView: imageView,
														  buttons: [])
		return modalLayoutView
	}
	
	func contentViewWith(title: String, bodyText: String, imageName: String?) -> UIView {
		guard imageName != nil else {
			let modalLayoutView = ModalLayoutView(title: title, body: bodyText, contentView: nil, buttons: [])
			return modalLayoutView
		}
		let imageView = NewsImageView(frame: .zero, image: UIImage(named: "gender-male" )!)
		imageView.sizeToFit()
		let modalLayoutView = ModalLayoutView(title: title,
														  body: bodyText,
														  contentView: imageView,
														  buttons: [])
		return modalLayoutView
	}
	
}

extension NewsViewController: OnboardPagingViewDelegate {
	func onboardPagingView(_ OnboardPagingView: OnboardPagingView, didUpdateTo currentPage: Int) {
		self.currentPage = currentPage
	}
}

protocol NewsViewControllerDelegate {
	func newsViewControllerDidFinish(_ newsViewController: NewsViewController)
}

//
//override func viewDidAppear(_ animated: Bool) {
//	super.viewDidAppear(animated)
//
//	viewIsAppearing = true
//
//	if #available(iOS 13.0, *) {
//		let hasShownContextMenuPopup = UserDefaults.standard.bool(forKey: GlobalKeys.HasShownContextMenuIntro)
//		if !hasShownContextMenuPopup {
//			DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//				let testVC = ContextMenuIntroViewController(delegate: self)
//				testVC.transitioningDelegate = self
//				testVC.modalPresentationStyle = .custom
//				self.present(testVC, animated: true)
//			}
//		}
//}
