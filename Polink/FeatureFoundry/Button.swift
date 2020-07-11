//
//  Button.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Button: UIButton {
	
	static let imageHeight: CGFloat = 36.0
	static let preferredHeight: CGFloat = 50.0
	static let preferredSecondaryHeight: CGFloat = 40.0
	static let preferredTertiaryHeight: CGFloat = 24.0
	
	enum Style {
		case primary
		case secondary
		case tertiary
		case custom
	}
	
	private let customView: UIView?
	private let style: Style
	public var tapHandler: () -> ()
	
	init(title: String?, image: UIImage?, view: UIView? = nil, style: Style = .primary, tapHandler: @escaping () -> ()) {
		self.style = style
		self.customView = view
		self.tapHandler = tapHandler
		super.init(frame: .zero)
		setTitle(title, for: .normal)
		setImage(image, for: .normal)
		addTarget(self, action: #selector(handleTap), for: .touchUpInside)
		
		if let view = view {
			view.isUserInteractionEnabled = false
			addSubview(view)
		}
		
		setupAppearance()
	}
	
	convenience init(title: String?, style: Style = .primary, tapHandler: @escaping () -> ()) {
		self.init(title: title, image: nil, style: style, tapHandler: tapHandler)
	}
	
	convenience init(title: String?, image: UIImage?, style: Style = .primary) {
		self.init(title: title, image: image, style: style, tapHandler: { })
	}
	
	convenience init(title: String?, style: Style = .primary) {
		self.init(title: title, image: nil, style: style, tapHandler: { })
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupAppearance() {
		
		let titleColor: UIColor
		let backgroundColor: UIColor
		let font: UIFont?
		
		switch style {
		case .primary:
			titleColor = .white
			backgroundColor = .black
			layer.cornerRadius = Appearance.cornerRadius
			font = UIFont(name: "Trim-Regular", size: 17.0)
			break
		case .secondary, .custom:
			titleColor = .black
			backgroundColor = UIColor.clear
			font = UIFont(name: "Trim-Regular", size: 17.0)
			break
		case .tertiary:
			titleColor = .secondaryLabel
			backgroundColor = UIColor.clear
			font = UIFont(name: "Trim-Regular", size: 13.0)
			break
		}
		
		setTitleColor(titleColor, for: .normal)
		self.backgroundColor = backgroundColor
		titleLabel?.font = font
	}
		
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		
		let height: CGFloat
		switch style {
		case .primary, .custom:
			height = Button.preferredHeight
		case .secondary:
			height = Button.preferredSecondaryHeight
		case .tertiary:
			height = Button.preferredTertiaryHeight
		}
		return CGSize(width: min(size.width, Appearance.preferredCompactWidth),
						  height: min(size.height, height))
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		customView?.frame = bounds
	}
	@objc private func handleTap() {
		tapHandler()
	}
}
