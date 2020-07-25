//
//  DistancePoint.swift
//  Polink
//
//  Created by Josh Valdivia on 20/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct DistancePoint {
	var userId: String
	var economyCoordinate: Double
	var governmentCoordinate: Double
	var societyCoordinate: Double
	var diplomacyCoordinate: Double
	
	init(source: ProfilePublic) {
		userId = source.uid
		guard let ideology = source.ideology else {
			print("initialised distancepoint with problems")
			self.economyCoordinate = 0
			self.diplomacyCoordinate = 0
			self.governmentCoordinate = 0
			self.societyCoordinate = 0
			return
		}
		economyCoordinate = ideology.econ
		governmentCoordinate = ideology.govt
		societyCoordinate = ideology.scty
		diplomacyCoordinate = ideology.dipl
	}
	
}
