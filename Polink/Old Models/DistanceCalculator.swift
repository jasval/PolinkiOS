//
//  DistanceCalculator.swift
//  Polink
//
//  Created by Josh Valdivia on 21/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import Accelerate

struct DistanceCalculator {
	private var collectionOfPoints: [DistancePoint]
	private var userPoint: Array<Double>
//	private var profileDistances: Dictionary<String, Double> = Dictionary<String,Double>() // Using a Dictionary to store the results might not be the best idea...
	private var profileDistances: [(String, Double)] = Array<(String,Double)>() // Instead we should consider using a tupple array to be able to sort them quicker.

	init(user: ProfilePublic) {
		self.collectionOfPoints = Array<DistancePoint>()
		
		// Everytime the array is initialised it will use the ideology of the user passed
		guard let ideology = user.ideology else {
			print("Initialised with problems")
			self.userPoint = []
			return
		}
		self.userPoint = {
			var vectors = Array<Double>()
			vectors.append(ideology.govt)
			vectors.append(ideology.econ)
			vectors.append(ideology.scty)
			vectors.append(ideology.dipl)
			return vectors
		}()
	}
	
	// Helper function for calculate Distances
	func createPoint(government: Double, economy: Double, society: Double, diplomacy: Double) -> [Double] {
		return [government, economy, society, diplomacy]
	}
	
	mutating func addDistancePointToCollection(point: DistancePoint) {
		collectionOfPoints.append(point)
	}
	
	mutating func calculateDistances() {
		for profile in collectionOfPoints {
			let point = createPoint(government: profile.governmentCoordinate, economy: profile.economyCoordinate, society: profile.societyCoordinate, diplomacy: profile.diplomacyCoordinate)
			print(userPoint)
			print(point)
			
			let distance = vDSP.distanceSquared(userPoint, point)
			
			profileDistances.append((profile.userId,distance))							// Storing in Array of Tuples
//			profileDistances[profile.userId] = distance 										// Storing in dictionary
			
			profileDistances.sort {																// Sort the array of tuple distances from highest to lowest
				return $0.1 > $1.1
			}
			
		}
	}
	
	func getIdOfPoint(position: Int) -> String {
		return profileDistances[position].0
	}
	
	func getProfileDistances() -> [(String,Double)] {
		return profileDistances
	}
	
}
