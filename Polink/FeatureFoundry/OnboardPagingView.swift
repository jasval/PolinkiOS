//
//  OnboardPagingView.swift
//  Polink
//
//  Created by Josh Valdivia on 09/07/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class OnboardPagingView: UIView {
	
	var pages: [UIView]
	
	private let scrollView: UIScrollView
	private let pageControl: UIPageControl
	
	private weak var delegate: OnboardPagingViewDelegate?
	
	init(pages: [UIView], delegate: OnboardPagingViewDelegate) {
		
		scrollView = UIScrollView()
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		
		pageControl = UIPageControl()
		pageControl.numberOfPages = pages.count
		
		self.pages = pages
		self.delegate = delegate
		
		super.init(frame: .zero)
		
		scrollView.delegate = self
		
		addSubview(scrollView)
		addSubview(pageControl)
		pages.forEach { scrollView.addSubview($0) }
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		scrollView.frame = bounds
		
		let pageControlSize = pageControl.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
		pageControl.frame = CGRect(x: (bounds.width - pageControlSize.width) / 2.0,
											y: bounds.height - pageControlSize.height,
											width: pageControlSize.width,
											height: pageControlSize.height)
		
		var xOrigin: CGFloat = 0.0
		pages.forEach { (page) in
			let pageFrame = CGRect(x: xOrigin, y: 0.0, width: bounds.width, height: bounds.height - pageControlSize.height)
			page.frame = pageFrame.insetBy(dx: Appearance.padding, dy: Appearance.padding)
			page.layoutSubviews()
			xOrigin += bounds.width
		}
		
		scrollView.contentSize = CGSize(width: xOrigin, height: bounds.height)
	}
	
	func updatePages(){
		pages.forEach( {scrollView.addSubview( $0 )} )
		layoutSubviews()
	}
}

extension OnboardPagingView: UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let index = floor(Double(scrollView.contentOffset.x / scrollView.bounds.width))
		let currentPage = Int(index)
		pageControl.currentPage = currentPage
		delegate?.onboardPagingView(self, didUpdateTo: currentPage)
	}
}

protocol OnboardPagingViewDelegate: class {
	func onboardPagingView(_ OnboardPagingView: OnboardPagingView, didUpdateTo currentPage: Int)
}
