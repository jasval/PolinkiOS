//
//  OnboardViewController.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class OnboardViewController: UIViewController {
	
	static private let backButtonWidth: CGFloat = 34.0
	
	private var modalLayoutView: ModalLayoutView?
	private let defaultBackgroundView: UIView
	
	var titleText: String? {
		return nil
	}
	
	var bodyText: String? {
		return nil
	}
	
	var buttons: [Button] {
		fatalError("Must Override")
	}
		
	var contentView: UIView {
		fatalError("Must Override")
	}
	
	var backgroundView: UIView? {
		return defaultBackgroundView
	}
	
	var newsUrl: URL?
	
	var layoutEmphasis: ModalLayoutView.LayoutEmphasis {
		get {
			guard let modalLayoutView = modalLayoutView else { return .content }
			return modalLayoutView.layoutEmphasis
		} set {
			guard let modalLayoutView = modalLayoutView else { return }
			modalLayoutView.layoutEmphasis = newValue
		}
	}
	
	var showButtonSeparator: Bool {
		get {
			guard let modalLayoutView = modalLayoutView else { return false }
			return modalLayoutView.showButtonSeparator
		} set {
			guard let modalLayoutView = modalLayoutView else { return }
			modalLayoutView.showButtonSeparator = newValue
		}
	}
	
	var showBackButton: Bool
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	init() {
		
		defaultBackgroundView = UIView()
		showBackButton = false
		super.init(nibName: nil, bundle: nil)
		showButtonSeparator = false
		
		updateBackgroundColors()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let modalLayoutView = ModalLayoutView(title: titleText, body: bodyText, contentView: contentView, buttons: buttons, backgroundView: backgroundView, url: newsUrl)
		self.modalLayoutView = modalLayoutView
		view = modalLayoutView
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(!showBackButton, animated: animated)
	}
	
	func updateText() {
		guard let modalLayoutView = modalLayoutView else { return }
		modalLayoutView.updateText(title: titleText, body: bodyText)
		view.setNeedsLayout()
		view.layoutIfNeeded()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateBackgroundColors()
	}
	
	func updateBackgroundColors() {
		defaultBackgroundView.backgroundColor = .white
	}
	
	func startAnimatingActivityIndicator() {
		modalLayoutView?.startAnimatingActivityIndicator()
	}
	
	func stopAnimatingActivityIndicator() {
		modalLayoutView?.stopAnimatingActivityIndicator()
	}
}
