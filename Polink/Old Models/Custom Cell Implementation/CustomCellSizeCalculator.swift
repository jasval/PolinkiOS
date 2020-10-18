//
//  CustomCellSizeCalculator.swift
//  Polink
//
//  Created by Josh Valdivia on 09/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import MessageKit

open class CustomCellSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
    // Customize this function implementation to size your content appropriately. This example simply returns a constant size
    // Refer to the default MessageKit cell implementations, and the Example App to see how to size a custom cell dynamically
        return CGSize(width: 300, height: 130)
    }
}
