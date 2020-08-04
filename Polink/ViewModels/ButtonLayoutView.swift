//
//  ButtonLayoutView.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class ButtonLayoutView: UIView {
	
	static let spacing: CGFloat = 16.0
	
	private var buttons: [Button] = [Button]()
	
	init(_ buttons: [Button]) {
		super.init(frame: .zero)
		addButtons(buttons)
	}
	
	convenience init(_ buttons: Button...) {
		self.init(buttons)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func addButtons(_ buttons: [Button]) {
		buttons.forEach { addButton($0) }
	}
	
	func addButton(_ button: Button) {
		buttons.append(button)
		addSubview(button)
	}
	
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		
		var width: CGFloat = 0.0
		var height: CGFloat = 0.0
		
		buttons.forEach { button in
			
			guard !button.isHidden else {
				return
			}
			
			let size = button.sizeThatFits(size)
			width = max(width, size.width)
			height += size.height + ButtonLayoutView.spacing
		}
		
		guard height > 0 else { return .zero }
		
		height -= ButtonLayoutView.spacing
		
		return CGSize(width: width, height: height)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		var yOrigin: CGFloat = 0.0
		
		buttons.forEach { button in
			
			guard !button.isHidden else {
				return
			}
			
			let size = button.sizeThatFits(bounds.size)
			button.frame = CGRect(x: (bounds.width - size.width) / 2.0,
										 y: yOrigin,
										 width: size.width,
										 height: size.height)
			
			yOrigin += size.height + ButtonLayoutView.spacing
		}
	}
}
