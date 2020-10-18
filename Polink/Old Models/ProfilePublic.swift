//
//  ProfilePublic.swift
//  Polink
//
//  Created by Josh Valdivia on 15/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

// The public profile structure in the database
struct ProfilePublic: Codable {
	let uid: String
	var country: String
	var city: String
	var ideology: IdeologyMapping?
	var listening: Bool
	var redFlags: Int
	var fcm: String
}
