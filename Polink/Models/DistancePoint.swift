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
		economyCoordinate = source.ideology?[K.ideologyAxes.econ] ?? 0
		governmentCoordinate = source.ideology?[K.ideologyAxes.govt] ?? 0
		societyCoordinate = source.ideology?[K.ideologyAxes.scty] ?? 0
		diplomacyCoordinate = source.ideology?[K.ideologyAxes.dipl] ?? 0
	}
	
}
