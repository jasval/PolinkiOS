//
//  Popup.swift
//  Polink
//
//  Created by Josh Valdivia on 08/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class Popup: UIView {
	
	fileprivate let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Whatever"
		return label
	}()
	
	fileprivate let subtitleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Whatever label"
		return label
	}()
	
	fileprivate let container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 24
		return container
	}()
	
	fileprivate lazy var stack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
		return stack
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .gray
		
		self.frame = UIScreen.main.bounds
		
		self.addSubview(container)
		container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		container.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
		container.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7).isActive = true
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
