//
//  TableViewCell.swift
//  Polink
//
//  Created by Josh Valdivia on 27/08/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
	init(roomIdentifier: String) {
		super.init(style: .subtitle, reuseIdentifier: roomIdentifier)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		textLabel?.frame = CGRect(contentView.frame.minX + 20, contentView.frame.minY + 5, contentView.frame.width / 2, 40)
		detailTextLabel?.frame = CGRect(contentView.frame.maxX - 30, contentView.frame.minY + 5, 50, 40)
	}
}
