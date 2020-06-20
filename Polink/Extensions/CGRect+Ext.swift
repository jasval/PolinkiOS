//
//  CGRect+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 18/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
	init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
		self.init(x:x, y:y, width:w, height:h)
	}
	
	// Return the center of a CGRect
	var center: CGPoint {
		return CGPoint(self.midX, self.midY)
	}
	
	// a CGRect centered at the center point of my CGRect
	func centeredOfSize(_ sz:CGSize) -> CGRect {
		let c = self.center
		let x = c.x - sz.width / 2.0
		let y = c.y - sz.height / 2.0
		
		return CGRect(x,y,sz.width, sz.height)
	}
}

extension CGSize {
	init(_ width: CGFloat,_ height:CGFloat) {
		self.init(width: width, height: height)
	}
	
	// Changing an existing CGSize by specifying the delta
	func withDelta(dw: CGFloat, dh: CGFloat) -> CGSize {
		return CGSize(self.width + dw, self.height + dh)
	}
}

extension CGPoint {
	init(_ x: CGFloat, _ y: CGFloat) {
		self.init(x:x, y:y)
	}
}
extension CGVector {
	init(_ dx: CGFloat, _ dy: CGFloat) {
		self.init(dx:dx, dy:dy)
	}
}
