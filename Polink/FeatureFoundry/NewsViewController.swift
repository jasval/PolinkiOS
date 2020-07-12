//
//  NewsViewController.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import SafariServices

class NewsViewController: OnboardViewController {
	
	
	override var buttons: [Button] {
		let doneButton = Button(title: "Let's chat about this!", style: .primary) { [unowned self] in
			
			let currentNews = self.newsToDisplay[self.currentPage]
			print(currentNews.title)
			
			self.delegate.newsWasSelected(currentNews)
			
			self.delegate.newsViewControllerDidFinish(self)
		}
		
		let safariButton = Button(title: "Open in Safari", style: .primary) { [unowned self] in
			
			let currentNews = self.newsToDisplay[self.currentPage]
			if let url = URL(string: currentNews.articleURL) {
				let config = SFSafariViewController.Configuration()
				config.entersReaderIfAvailable = true
				
				let vc = SFSafariViewController(url: url, configuration: config)
				vc.modalPresentationStyle = .popover
				self.present(vc, animated: true)
				
			}
			
		}
		
		return [safariButton,doneButton]
	}
	
	// It was UIView before
	override var contentView: OnboardPagingView {

		var viewsToDisplay = Array<UIView>()
		newsToDisplay.forEach { (news) in
			let imageURL = URL(string: news.imageURL ?? "")
			let url = URL(string: news.articleURL)
			print(imageURL as Any)
			let vc = contentViewWith(title: news.title, bodyText: news.description ?? "", imageURL: imageURL, url: url) as! ModalLayoutView
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
	
	func contentViewWith(title: String, bodyText: String, imageURL: URL?, url: URL?) -> UIView {
		guard let urlImage = imageURL else {
			let modalLayoutView = ModalLayoutView(title: title, body: bodyText, contentView: nil, buttons: [], url: url)
			return modalLayoutView
		}
		let imageView = UIImageView()
		imageView.kf.setImage(with: urlImage, placeholder: UIImage(named:"placeholder-news"))
		let modalLayoutView = ModalLayoutView(title: title,
														  body: bodyText,
														  contentView: imageView,
														  buttons: [], url: url)
		return modalLayoutView
	}
	
	func contentViewWith(title: String, bodyText: String, imageName: String?) -> UIView {
		guard imageName != nil else {
			let modalLayoutView = ModalLayoutView(title: title, body: bodyText, contentView: nil, buttons: [], url: nil)
			return modalLayoutView
		}
		let imageView = NewsImageView(frame: .zero, image: UIImage(named: "placeholder-news" )!)
		imageView.sizeToFit()
		let modalLayoutView = ModalLayoutView(title: title,
														  body: bodyText,
														  contentView: imageView,
														  buttons: [], url: nil)
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
	func newsWasSelected(_ newsToSend: News)
}
