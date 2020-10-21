//
//  LocalizedString.swift
//  Polink
//
//  Created by Jasper Valdivia on 18/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

/// Returns a localized string, using the main bundle if one is not specified.
public func LocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

public class LocalizedAction {
}
