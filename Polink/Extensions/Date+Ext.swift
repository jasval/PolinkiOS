//
//  Date+Ext.swift
//  Polink
//
//  Created by Josh Valdivia on 09/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

extension Date {
    func getFormattedDate(format: String = "yyy-MM-dd") -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
