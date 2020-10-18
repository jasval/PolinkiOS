//
//  NewsImageView.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class NewsImageView: UIView {
	
	private var imageView: UIImageView
	private var image: UIImage?
	
	override init(frame: CGRect) {
		self.imageView = UIImageView(frame: frame)
		super.init(frame: frame)
	}
	
	init(frame: CGRect, url: URL) {
		self.imageView = UIImageView(frame: frame)
		imageView.load(url: url)
		super.init(frame: frame)
	}
	
	// Old initialiser
	init(frame: CGRect, image: UIImage) {
		self.image = image
		self.imageView = UIImageView()
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
