//
//  quizBrain.swift
//  polink.dev
//
//  Created by Jose Saldana on 05/02/2020.
//  Quiz questions were taken from 8values project: https://github.com/8values/
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import UIKit

struct QuizBrain {
    /*
    // MARK: - Variables
     */
    //    Maximum scores of the test calculated in every initialisation
    var maxEcon:Double = 0
    var maxDipl:Double = 0
    var maxGovt:Double = 0
    var maxScty:Double = 0
    
    //    User scores initialised at 0
    var econ:Double = 0
    var dipl:Double = 0
    var govt:Double = 0
    var scty:Double = 0
    
    //  Question Iterators
    var questionNo:Int = 0
    var prevQuestion:Int?
    
    
    /*
    // MARK: - Functions
     */
    mutating func nextQuestion(_ multiplier: Double) {
        econ += multiplier * (quizList[questionNo].effect[K.ideologyAxes.econ] ?? 0)
        dipl += multiplier * (quizList[questionNo].effect[K.ideologyAxes.dipl] ?? 0)
        govt += multiplier * (quizList[questionNo].effect[K.ideologyAxes.govt] ?? 0)
        scty += multiplier * (quizList[questionNo].effect[K.ideologyAxes.scty] ?? 0)
        if questionNo < quizList.count {
            prevQuestion = questionNo
            questionNo += 1
        } else {
            print("No more elements in the array")
        }
    }
    mutating func initQuiz() {
        questionNo = 0
        for i in 0..<quizList.count {
            maxEcon += abs(quizList[i].effect[K.ideologyAxes.econ] ?? 0)
            maxDipl += abs(quizList[i].effect[K.ideologyAxes.dipl] ?? 0)
            maxGovt += abs(quizList[i].effect[K.ideologyAxes.govt] ?? 0)
            maxScty += abs(quizList[i].effect[K.ideologyAxes.scty] ?? 0)
        }
    }
    func calcScores(_ userScore: Double, maxScore: Double) -> Double{
        return round(100*(100*(maxScore+userScore)/(2*maxScore)))/100
    }
    func getProgress() -> Float{
        return Float(questionNo + 1) / Float(quizList.count)
    }
    /*
    // MARK: - Question List
    //    List of essential profiling questions
    }
    */
    let quizList: [Question] = [
        Question("Oppression by corporations is more of a concern than oppression by governments.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("It is necessary for the government to interviene in the economy to protect consumers", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("The freer the markets, the freer the people.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question("It is better to maintain a balanced budget than to endure welfare for all citizens.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question("Publicly-funded research is more beneficial to the people than leaving it to the market.", econ: 10, dipl: 0, govt: 0, scty: 10),
        Question("Tariffs on international trade are important to encourage local production.", econ: 5, dipl: 0, govt: -10, scty: 0),
        Question("From each according to his ability, to each according to his needs.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("It would be best if social programs were abolished in favor of private charity.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question("Taxes should be increased on the rich to provide for the poor.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("Inheritance is a legitimate form of wealth.", econ: -10, dipl: 0, govt: 0, scty: -5),
        Question("Basic utilities like roads and electricity should be publicly owned.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("Government intervention is a threat to the economy.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question("Those with a greater ability to pay should receive better healthcare.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question("Quality education is a right of all people.", econ: 10, dipl: 0, govt: 0, scty: 5),
        Question("The means of production should belong to the workers who use them.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("The United Nations should be abolished.", econ: 0, dipl: -10, govt: -5, scty: 0),
        Question("Military action by our nation is often necessary to protect it.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question("I support regional unions, such as the European Union.", econ: -5, dipl: -10, govt: -5, scty: 0),
        Question("It is important to maintain our national sovereignty.", econ: 0, dipl: -10, govt: -5, scty: 0),
        Question("A united world government would be beneficial to mankind.", econ: 0, dipl: 10, govt: 0, scty: 0),
        Question("It is more important to retain peaceful relations than to further our strength.", econ: 0, dipl: 10, govt: 0, scty: 0),
        Question("Wars do not need to be justified to other countries.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question("Military spending is a waste of money.", econ: 0, dipl: 10, govt: 10, scty: 0),
        Question("International aid is a waste of money.", econ: -5, dipl: -10, govt: 0, scty: 0),
        Question("My nation is great.", econ: 0, dipl: -10, govt: 0, scty: 0),
        Question("Research should be conducted on an international scale.", econ: 0, dipl: 10, govt: 0, scty: 10),
        Question("Governments should be accountable to the international community.", econ: 0, dipl: 10, govt: 5, scty: 0),
        Question("Even when protesting an authoritarian government, violence is not acceptable.", econ: 0, dipl: 5, govt: -5, scty: 0),
        Question("My religious values should be spread as much as possible.", econ: 0, dipl: -5, govt: -10, scty: -10),
        Question("Our nation's values should be spread as much as possible.", econ: 0, dipl: -10, govt: -5, scty: 0),
        Question("It is very important to maintain law and order.", econ: 0, dipl: -5, govt: -10, scty: -5),
        Question("The general populace makes poor decisions.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question("Victimless crimes (such as drug use) should not be crimes at all.", econ: 0, dipl: 0, govt: 10, scty: 0),
        Question("The sacrifice of some civil liberties is necessary to protect us from acts of terrorism.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question("Government surveillance is necessary in the modern world.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question("The very existence of the state is a threat to our liberty.", econ: 0, dipl: 0, govt: 10, scty: 0),
        Question("Regardless of political opinions, it is important to side with your country.", econ: 0, dipl: -10, govt: -10, scty: -5),
        Question("All authority should be questioned.", econ: 0, dipl: 0, govt: 10, scty: 5),
        Question("A hierarchical state is best.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question("It is important that the government follows the majority opinion, even if it is wrong.", econ: 0, dipl: 0, govt: 10, scty: 0),
        Question("The stronger the leadership, the better.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question("Democracy is more than a decision-making process.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question("Environmental regulations are essential.", econ: 5, dipl: 0, govt: 0, scty: 10),
        Question("A better world will come from automation, science, and technology.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question("Children should be educated in religious or traditional values.", econ: 0, dipl: 0, govt: -5, scty: -10),
        Question("Traditions are of no value on their own.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question("Religion should play a role in government.", econ: 0, dipl: 0, govt: -10, scty: -10),
        Question("Churches should be taxed the same way other institutions are taxed.", econ: 5, dipl: 0, govt: 0, scty: 10),
        Question("Climate change is currently one of the greatest threats to our way of life.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question("It is important that we work as a united world to combat climate change.", econ: 0, dipl: 10, govt: 0, scty: 10),
        Question("Society was better many years ago than it is now.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question("It is important that we maintain the traditions of our past.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question("It is important that we think in the long term, beyond our lifespans.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question("Reason is more important than maintaining our culture.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question("Drug use should be legalized or decriminalized.", econ: 0, dipl: 0, govt: 10, scty: 2),
        Question("Same-sex marriage should be legal.", econ: 0, dipl: 0, govt: 10, scty: 10),
        Question("No cultures are superior to others.", econ: 0, dipl: 10, govt: 5, scty: 10),
        Question("Sex outside marriage is immoral.", econ: 0, dipl: 0, govt: -5, scty: -10),
        Question("If we accept migrants at all, it is important that they assimilate into our culture.", econ: 0, dipl: 0, govt: -5, scty: -10),
        Question("Abortion should be prohibited in most or all cases.", econ: 0, dipl: 0, govt: -10, scty: -10),
        Question("Gun ownership should be prohibited for those without a valid reason.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question("I support single-payer, universal healthcare.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question("Prostitution should be illegal.", econ: 0, dipl: 0, govt: -10, scty: -10),
        Question("Maintaining family values is essential.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question("To chase progress at all costs is dangerous.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question("Genetic modification is a force for good, even on humans.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question("We should open our borders to immigration.", econ: 0, dipl: 10, govt: 10, scty: 0),
        Question("Governments should be as concerned about foreigners as they are about their own citizens.", econ: 0, dipl: 10, govt: 0, scty: 0),
        Question("All people - regardless of factors like culture or sexuality - should be treated equally.", econ: 10, dipl: 10, govt: 10, scty: 10),
        Question("It is important that we further my group's goals above all others.", econ: -10, dipl: -10, govt: -10, scty: -10),
    ]
    
    
}
