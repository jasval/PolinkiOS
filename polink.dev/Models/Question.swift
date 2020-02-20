//
//  Question.swift
//  polink.dev
//
//  Created by Jose Saldana on 05/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct Question {
    var prompt: String?
    var effect: [String : Double]
    
    
    init(_ prompt: String, econ: Double, dipl: Double, govt : Double, scty: Double) {
        self.prompt = prompt
        effect = [
            K.ideologyAxes.econ: econ,
            K.ideologyAxes.dipl: dipl,
            K.ideologyAxes.govt: govt,
            K.ideologyAxes.scty: scty
        ]
    }
}
