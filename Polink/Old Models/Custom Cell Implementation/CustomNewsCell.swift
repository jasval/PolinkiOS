//
//  CustomNewsCell.swift
//  Polink
//
//  Created by Josh Valdivia on 09/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import MessageKit

open class CustomNewsCell: UICollectionViewCell {
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        self.contentView.backgroundColor = UIColor.red
    }
}
