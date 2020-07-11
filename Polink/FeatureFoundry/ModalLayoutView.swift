//
//  ModalLayoutView.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class ModalLayoutView: UIView {
	
	enum LayoutEmphasis {
		case content
		case text
		case none
	}
	
	static let minTextHeight: CGFloat = 140.0
	static let preferredTextWidth: CGFloat = 340.0
	static let activityIndicatorOffsetFromBottom: CGFloat = 40.0
	static var bodyTextPadding: CGFloat {
		return 0.4
	}
	
	public var showButtonSeparator: Bool = false
	
	public var layoutEmphasis: LayoutEmphasis = .content {
		didSet {
			setNeedsLayout()
		}
	}
	
	private let titleLabel: UILabel
	private let bodyLabel: UILabel
	private let textScrollView: UIScrollView
	private let contentView: UIView?
	private let buttonSeparator: UIView
	private let buttonBackground: UIVisualEffectView
	private let buttonLayoutView: ButtonLayoutView
	private let backgroundView: UIView?
	private let activityIndicator: UIActivityIndicatorView
	
	private var hasText: Bool = false
	
	init(title: String?, body: String?, contentView: UIView?, buttons: [Button], backgroundView: UIView? = nil) {
		
		titleLabel = UILabel()
//		titleLabel.font = FontFamily.defaultFamily.font(.title2)
		titleLabel.textColor = .black
		titleLabel.textAlignment = .center
		titleLabel.numberOfLines = 0
		
		bodyLabel = UILabel()
//		bodyLabel.font = FontFamily.defaultFamily.font(.body)
		bodyLabel.textColor = .black
		bodyLabel.textAlignment = .center
		bodyLabel.numberOfLines = 0
		
		textScrollView = UIScrollView()
		textScrollView.indicatorStyle = .black
		
		self.contentView = contentView
		self.buttonLayoutView = ButtonLayoutView(buttons)
		
		activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .gray
		
		buttonSeparator = UIView()
		buttonSeparator.isHidden = !showButtonSeparator
		
		buttonBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
		
		self.backgroundView = backgroundView
		
		super.init(frame: .zero)
		
		if let backgroundView = backgroundView {
			addSubview(backgroundView)
		}
		if contentView != nil {
			addSubview(contentView!)
		}
		addSubview(buttonBackground)
		addSubview(textScrollView)
		textScrollView.addSubview(titleLabel)
		textScrollView.addSubview(bodyLabel)
		addSubview(buttonLayoutView)
		addSubview(activityIndicator)
		addSubview(buttonSeparator)
		
		updateBackgroundColors()
		updateText(title: title, body: body)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return size
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		updateBackgroundColors()
	}
	
	private func updateBackgroundColors() {
//		buttonSeparator.backgroundColor = ColorUtil.UIColorFrom(.backgroundSecondary, traitCollection: traitCollection)
		buttonSeparator.backgroundColor = .gray
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if let backgroundView = backgroundView {
			backgroundView.frame = bounds
		}
		
		let buttonsHeight = buttonLayoutView.isHidden ? 0.0 : buttonLayoutView.sizeThatFits(bounds.size).height
		let hasButtons = buttonsHeight > 0.0
		
		let contentHeight: CGFloat
		let titleTextSize: CGSize
		let bodyTextSize: CGSize
		let textWidth = min(ModalLayoutView.preferredTextWidth, bounds.width - 2.0 * Appearance.padding)
		let textHeight: CGFloat
		
		if hasText {
			
			titleTextSize = titleLabel.sizeThatFits(CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude))
			bodyTextSize = bodyLabel.sizeThatFits(CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude))
			
			let preferredContentRatio: CGFloat
			switch layoutEmphasis {
			case .content:
				preferredContentRatio = 0.35
			case .text:
				preferredContentRatio = 0.5
			case .none:
				preferredContentRatio = .greatestFiniteMagnitude
			}
			
			let textOffsetFromBottom = min(260.0, bounds.height * preferredContentRatio)
			
			// Padding: 1x above text. 1x below buttons. 2x between text/buttons
			let padding = hasButtons ? 4.0 * Appearance.padding : 0.0
			let minTextHeight = min(titleTextSize.height + bodyTextSize.height + ModalLayoutView.bodyTextPadding, ModalLayoutView.minTextHeight)
			textHeight = max(textOffsetFromBottom - buttonsHeight - padding - layoutMargins.bottom, minTextHeight)
			contentHeight = bounds.height - layoutMargins.top - textHeight - buttonsHeight - padding - layoutMargins.bottom
		} else {
			titleTextSize = .zero
			bodyTextSize = .zero
			textHeight = 0.0
			let padding = hasButtons ? 2.0 * Appearance.padding : 0.0
			contentHeight = bounds.height - layoutMargins.top - layoutMargins.bottom - buttonsHeight - padding
		}
		
		// ContentView is full width and resides above buttons.
		// If content view is a scrollview, we layout full screens and
		// put a blur view behind the buttons
		if let scrollView = contentView as? UIScrollView {
			scrollView.frame = CGRect(x: 0.0, y: layoutMargins.top, width: bounds.width, height: bounds.height)
			scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bounds.height - contentHeight, right: 0.0)
			scrollView.scrollIndicatorInsets = scrollView.contentInset
			buttonBackground.frame = CGRect(x: 0.0, y: layoutMargins.top + contentHeight, width: bounds.width, height: bounds.height - contentHeight)
			buttonBackground.isHidden = false
		} else {
			// added optional
			contentView?.frame = CGRect(x: 0.0, y: layoutMargins.top, width: bounds.width, height: contentHeight)
			buttonBackground.isHidden = true
		}
		
		// Buttons have padding around all edges
		buttonLayoutView.frame = CGRect(x: Appearance.padding,
												  y: bounds.height - buttonsHeight - Appearance.padding - layoutMargins.bottom,
												  width: bounds.width - 2.0 * Appearance.padding,
												  height: buttonsHeight)
		buttonLayoutView.layoutSubviews()
		
		buttonSeparator.frame = CGRect(x: 0.0, y: buttonLayoutView.frame.minY - Appearance.padding, width: bounds.width, height: 1.0)
		buttonSeparator.isHidden = !showButtonSeparator || !hasButtons
		
		activityIndicator.center = CGPoint(x: bounds.width / 2.0, y: bounds.height - layoutMargins.bottom - ModalLayoutView.activityIndicatorOffsetFromBottom)
		
		guard hasText else { return }
		//added optional to content view --> This could lead to serious problems
		textScrollView.frame = CGRect(x: 0.0, y: contentView?.frame.maxY ?? 100 + Appearance.padding, width: bounds.width, height: textHeight)
		
		titleLabel.frame = CGRect(x: (bounds.width - textWidth) / 2.0, y: 0.0, width: textWidth, height: titleTextSize.height)
		
		bodyLabel.frame = CGRect(x: (bounds.width - textWidth) / 2.0, y: titleLabel.frame.maxY + ModalLayoutView.bodyTextPadding, width: textWidth, height: bodyTextSize.height)
		
		textScrollView.contentSize = CGSize(width: bounds.width, height: bodyLabel.frame.maxY)
	}
	
	public func updateText(title: String?, body: String?) {
		
		if let _ = title {
			hasText = true
		} else if let _ = body {
			hasText = true
		} else {
			hasText = false
		}
		
		titleLabel.text = title
		bodyLabel.text = body
		self.setNeedsLayout()
	}
	
	public func startAnimatingActivityIndicator() {
		self.activityIndicator.startAnimating()
		self.buttonLayoutView.isHidden = true
	}
	
	public func stopAnimatingActivityIndicator() {
		self.activityIndicator.stopAnimating()
		self.buttonLayoutView.isHidden = false
		setNeedsLayout()
		layoutIfNeeded()
	}
	
	// MARK: - Getter
	
	public enum TextualInformation: String {
		case title
		case legend
		case url
		case image
	}
	
	func getTextualInformation() -> [TextualInformation: String?]{
		var dictionary: [TextualInformation	: String?] = [:]
		dictionary[TextualInformation.title] = self.titleLabel.text
		dictionary[TextualInformation.legend] = self.bodyLabel.text
		dictionary[TextualInformation.url] = self.titleLabel.text
		dictionary[TextualInformation.image] = self.titleLabel.text
		return dictionary
	}
	
}
