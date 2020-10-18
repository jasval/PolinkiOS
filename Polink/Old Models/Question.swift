//
//  Question.swift
//  Polink
//
//  Created by Jose Saldana on 05/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct Question {
	
	var number: Int
    var prompt: String?
    var effect: [String : Double?]
    
    
	init(id: Int, _ prompt: String, econ: Double, dipl: Double, govt : Double, scty: Double) {
        self.prompt = prompt
        effect = [
            K.ideologyAxes.econ: econ,
            K.ideologyAxes.dipl: dipl,
            K.ideologyAxes.govt: govt,
            K.ideologyAxes.scty: scty
        ]
		self.number = id
    }
}

extension Question: Persistable {
	public init(managedObject: QuestionObject) {
		prompt = managedObject.prompt
		number = managedObject.number
		effect = [
			K.ideologyAxes.econ: managedObject.effect?.Economy,
			K.ideologyAxes.dipl: managedObject.effect?.Diplomacy,
			K.ideologyAxes.govt: managedObject.effect?.Government,
			K.ideologyAxes.scty: managedObject.effect?.Society
		]
	}
	
	public func managedObject() -> QuestionObject {
		let object = QuestionObject()
		object.prompt = prompt ?? ""
		object.effect = Effect()
		object.number = number
		object.effect?.Economy = effect[K.ideologyAxes.econ]!!
		object.effect?.Diplomacy = effect[K.ideologyAxes.dipl]!!
		object.effect?.Government = effect[K.ideologyAxes.govt]!!
		object.effect?.Society = effect[K.ideologyAxes.scty]!!
		
		return object
	}
	
}
