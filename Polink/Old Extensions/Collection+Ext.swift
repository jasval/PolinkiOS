//
//  Collection+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 16/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension Collection {
	func choose(_ n: Int) -> ArraySlice<Element> {shuffled().prefix(n)}
}
