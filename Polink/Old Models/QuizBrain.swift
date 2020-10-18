//
//  QuizBrain.swift
//  Polink
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
    
    
    
    //  Question Iterators
    var questionNo:Int = 0
    
    struct Answer {
        var econ = 0.0, dipl = 0.0, govt = 0.0, scty = 0.0
    }
    
    enum QuizError: Error {
        case emptyScores
        case badCalculation
        case limitOutOfBounds
    }
    
    // MARK: - Embedded struct for a stack of generics
    
    // A stack to keep tabs on answers scores for easy backtracing
    struct Stack<Element> {
        fileprivate var answerArray: [Element] = []
        
        var isEmpty: Bool {
            answerArray.isEmpty
        }
        
        var count: Int {
            answerArray.count
        }
        
        mutating func push(_ element: Element) {
            answerArray.append(element)
        }
        
        mutating func pop() -> Element? {
            answerArray.popLast()
        }
        
        func peek() -> Element? {
            answerArray.last
        }
    }
	var questionStack: Array<Question>?
    var answerStack = Stack<Answer>()
	var previousQuestions: Array<Question>?
	private var previousResults: Answer?
    
    // MARK: - Functions
    
    mutating func nextQuestion(_ multiplier: Double) {
        
        // logic to create an answer initialised to 0 if stack is empty or to previous scores otherwise
        var newAnswer:Answer?
        if answerStack.isEmpty {
            newAnswer = Answer()
        } else {
            if let previousAnswer = answerStack.peek() {
                newAnswer = Answer(econ: previousAnswer.econ, dipl: previousAnswer.dipl, govt: previousAnswer.govt, scty: previousAnswer.scty)
            }
        }
		newAnswer?.econ += multiplier * ((questionStack?[questionNo].effect[K.ideologyAxes.econ] ?? 0)!)
		newAnswer?.dipl += multiplier * ((questionStack?[questionNo].effect[K.ideologyAxes.dipl] ?? 0)!)
		newAnswer?.govt += multiplier * ((questionStack?[questionNo].effect[K.ideologyAxes.govt] ?? 0)!)
		newAnswer?.scty += multiplier * ((questionStack?[questionNo].effect[K.ideologyAxes.scty] ?? 0)!)
        
        answerStack.push(newAnswer!)
		if questionStack != nil {
			if questionNo < questionStack!.count {
				questionNo += 1
			} else {
				print("No more questions")
			}
		}
    }
	
    mutating func prevQuestion() {
        _ = answerStack.pop()
        if questionNo > 0 {
            questionNo -= 1
        } else {
            print("This is already the first question")
        }
    }
    
	mutating func initQuiz(with previousQuestions: [Question]? = nil, previousResults: IdeologyMapping? = nil) {
        
		self.previousQuestions = previousQuestions
		
		if previousQuestions == nil {
			questionNo = 0
			questionStack = Array(questionRepository.choose(55))
			if questionStack != nil {
				for i in 0..<questionStack!.count {
					maxEcon += abs((questionStack?[i].effect[K.ideologyAxes.econ] ?? 0)!)
					maxDipl += abs((questionStack?[i].effect[K.ideologyAxes.dipl] ?? 0)!)
					maxGovt += abs((questionStack?[i].effect[K.ideologyAxes.govt] ?? 0)!)
					maxScty += abs((questionStack?[i].effect[K.ideologyAxes.scty] ?? 0)!)
				}
			}
		} else {
			questionNo = 0
			questionStack = [Question]()
			for element in questionRepository {
				if previousQuestions!.contains(where: { (q) -> Bool in
					element.number == q.number
				}) {
					return
				} else {
					questionStack?.append(element)
				}
			}
			
			for i in 0..<questionStack!.count {
				maxEcon += abs((questionStack?[i].effect[K.ideologyAxes.econ] ?? 0)!)
				maxDipl += abs((questionStack?[i].effect[K.ideologyAxes.dipl] ?? 0)!)
				maxGovt += abs((questionStack?[i].effect[K.ideologyAxes.govt] ?? 0)!)
				maxScty += abs((questionStack?[i].effect[K.ideologyAxes.scty] ?? 0)!)
			}
			self.previousResults = Answer(econ: previousResults?.econ ?? 0,
										  dipl: previousResults?.dipl ?? 0,
										  govt: previousResults?.govt ?? 0,
										  scty: previousResults?.scty ?? 0)
		}
    }
    
    
    func calcScores() throws -> Answer {
        //round(100*(100*(maxScore+userScore)/(2*maxScore)))/100
		if var scores = answerStack.peek() {
			scores.dipl = round( 100 * ( 100 * ( maxDipl + scores.dipl) / (2 * maxDipl))) / 100
			scores.govt = round( 100 * ( 100 * ( maxGovt + scores.govt) / (2 * maxGovt))) / 100
			scores.econ = round( 100 * ( 100 * ( maxEcon + scores.econ) / (2 * maxEcon))) / 100
			scores.scty = round( 100 * ( 100 * ( maxScty + scores.scty) / (2 * maxScty))) / 100
			
			if previousQuestions != nil {
				let percentPrevious = Double(previousQuestions!.count) / Double(questionRepository.count)
				let percentCurrent = Double(answerStack.count) / Double(questionRepository.count)
				
				scores.dipl = (percentPrevious * previousResults!.dipl) + (percentCurrent * scores.dipl)
				scores.econ = (percentPrevious * previousResults!.econ) + (percentCurrent * scores.econ)
				scores.govt = (percentPrevious * previousResults!.govt) + (percentCurrent * scores.govt)
				scores.scty = (percentPrevious * previousResults!.scty) + (percentCurrent * scores.scty)
			}
			
			return scores
		} else {
			throw QuizError.badCalculation
		}
    }
	
    func getProgress(_ movement: Int) -> Float {
		Float(questionNo + movement) / Float(questionStack?.count ?? 0)
    }
    
	func getQuestionStack() -> [Question]? {
		questionStack
	}
	
    // MARK: - Question List
    //    List of essential profiling questions
    let questionRepository: [Question] = [
		Question(id: 0, "Openness about sexual matters, is detrimental to society.", econ: 0, dipl: 0, govt: 0, scty: -10),
		Question(id: 1, "Oppression by corporations is more of a concern than oppression by governments.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 2, "It is necessary for the government to intervene in the economy to protect consumers", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 3, "The freer the markets, the freer the people.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question(id: 4, "It is better to maintain a balanced budget than to endure welfare for all citizens.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question(id: 5, "Publicly-funded research is more beneficial to the people than leaving it to the market.", econ: 10, dipl: 0, govt: 0, scty: 10),
        Question(id: 6, "Tariffs on international trade are important to encourage local production.", econ: 5, dipl: 0, govt: -10, scty: 0),
        Question(id: 7, "From each according to his ability, to each according to his needs.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 8, "It would be best if social programmes were abolished in favor of private charity.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question(id: 9, "Taxes should be increased on the rich to provide for the poor.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 10, "Inheritance is a legitimate form of wealth.", econ: -10, dipl: 0, govt: 0, scty: -5),
        Question(id: 11, "Basic utilities like roads and electricity should be publicly owned.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 12, "Government intervention is a threat to the economy.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question(id: 13, "Those with a greater ability to pay should receive better healthcare.", econ: -10, dipl: 0, govt: 0, scty: 0),
        Question(id: 14, "Quality education is a right of all people.", econ: 10, dipl: 0, govt: 0, scty: 5),
        Question(id: 15, "The means of production should belong to the workers who use them.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 16, "The United Nations should be abolished.", econ: 0, dipl: -10, govt: -5, scty: 0),
        Question(id: 17, "Military action by our nation is often necessary to protect it.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question(id: 18, "I support regional unions, such as the European Union.", econ: -5, dipl: -10, govt: -5, scty: 0),
        Question(id: 19, "It is important to maintain our national sovereignty.", econ: 0, dipl: -10, govt: -5, scty: 0),
        Question(id: 20, "A united world government would be beneficial to mankind.", econ: 0, dipl: 10, govt: 0, scty: 0),
        Question(id: 21, "It is more important to retain peaceful relations than to further our strength.", econ: 0, dipl: 10, govt: 0, scty: 0),
        Question(id: 22, "Wars do not need to be justified to other countries.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question(id: 23, "Military spending is a waste of money.", econ: 0, dipl: 10, govt: 10, scty: 0),
        Question(id: 24, "International aid is a waste of money.", econ: -5, dipl: -10, govt: 0, scty: 0),
        Question(id: 25, "My nation is great.", econ: 0, dipl: -10, govt: 0, scty: 0),
        Question(id: 26, "Research should be conducted on an international scale.", econ: 0, dipl: 10, govt: 0, scty: 10),
        Question(id: 27, "Governments should be accountable to the international community.", econ: 0, dipl: 10, govt: 5, scty: 0),
		Question(id: 28, "Even when protesting an authoritarian government, violence is not acceptable.", econ: 0, dipl: 5, govt: -5, scty: 0),
        Question(id: 29, "My religious values should be spread as much as possible.", econ: 0, dipl: -5, govt: -10, scty: -10),
        Question(id: 30, "Our nation's values should be spread as much as possible.", econ: 0, dipl: -10, govt: -5, scty: 0),
        Question(id: 31, "It is very important to maintain law and order.", econ: 0, dipl: -5, govt: -10, scty: -5),
        Question(id: 32, "The general populace makes poor decisions.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question(id: 33, "Victimless crimes (such as drug use) should not be crimes at all.", econ: 0, dipl: 0, govt: 10, scty: 0),
        Question(id: 34, "The sacrifice of some civil liberties is necessary to protect us from acts of terrorism.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question(id: 35, "Government surveillance is necessary in the modern world.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question(id: 36, "The very existence of the state is a threat to our liberty.", econ: 0, dipl: 0, govt: 10, scty: 0),
        Question(id: 37, "Regardless of political opinions, it is important to side with your country.", econ: 0, dipl: -10, govt: -10, scty: -5),
        Question(id: 38, "All authority should be questioned.", econ: 0, dipl: 0, govt: 10, scty: 5),
        Question(id: 39, "A hierarchical state is best.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question(id: 40, "It is important that the government follows the majority opinion, even if it is wrong.", econ: 0, dipl: 0, govt: 10, scty: 0),
        Question(id: 41, "The stronger the leadership, the better.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question(id: 42, "Democracy is more than a decision-making process.", econ: 0, dipl: -10, govt: -10, scty: 0),
        Question(id: 43, "Environmental regulations are essential.", econ: 5, dipl: 0, govt: 0, scty: 10),
        Question(id: 44, "A better world will come from automation, science, and technology.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question(id: 45, "Children should be educated in religious or traditional values.", econ: 0, dipl: 0, govt: -5, scty: -10),
        Question(id: 46, "Traditions are of no value on their own.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question(id: 47, "Religion should play a role in government.", econ: 0, dipl: 0, govt: -10, scty: -10),
        Question(id: 48, "Churches should be taxed the same way other institutions are taxed.", econ: 5, dipl: 0, govt: 0, scty: 10),
        Question(id: 49, "Climate change is currently one of the greatest threats to our way of life.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question(id: 50, "It is important that we work as a united world to combat climate change.", econ: 0, dipl: 10, govt: 0, scty: 10),
        Question(id: 51, "Society was better many years ago than it is now.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question(id: 52, "It is important that we maintain the traditions of our past.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question(id: 53, "It is important that we think in the long term, beyond our lifespans.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question(id: 54, "Reason is more important than maintaining our culture.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question(id: 55, "Drug use should be legalized or decriminalized.", econ: 0, dipl: 0, govt: 10, scty: 2),
        Question(id: 56, "Same-sex marriage should be legal.", econ: 0, dipl: 0, govt: 10, scty: 10),
        Question(id: 57, "No cultures are superior to others.", econ: 0, dipl: 10, govt: 5, scty: 10),
        Question(id: 58, "Sex outside marriage is immoral.", econ: 0, dipl: 0, govt: -5, scty: -10),
        Question(id: 59, "If we accept migrants at all, it is important that they assimilate into our culture.", econ: 0, dipl: 0, govt: -5, scty: -10),
        Question(id: 60, "Abortion should be prohibited in most or all cases.", econ: 0, dipl: 0, govt: -10, scty: -10),
        Question(id: 61, "Gun ownership should be prohibited for those without a valid reason.", econ: 0, dipl: 0, govt: -10, scty: 0),
        Question(id: 62, "I support single-payer, universal healthcare.", econ: 10, dipl: 0, govt: 0, scty: 0),
        Question(id: 63, "Prostitution should be illegal.", econ: 0, dipl: 0, govt: -10, scty: -10),
        Question(id: 64, "Maintaining family values is essential.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question(id: 65, "To chase progress at all costs is dangerous.", econ: 0, dipl: 0, govt: 0, scty: -10),
        Question(id: 66, "Genetic modification is a force for good, even on humans.", econ: 0, dipl: 0, govt: 0, scty: 10),
        Question(id: 67, "We should open our borders to immigration.", econ: 0, dipl: 10, govt: 10, scty: 0),
        Question(id: 68, "Governments should be as concerned about foreigners as they are about their own citizens.", econ: 0, dipl: 10, govt: 0, scty: 0),
        Question(id: 69, "All people - regardless of factors like culture or sexuality - should be treated equally.", econ: 10, dipl: 10, govt: 10, scty: 10),
        Question(id: 70, "It is important that we further my group's goals above all others.", econ: -10, dipl: -10, govt: -10, scty: -10),
		Question(id: 71, "If economic globalisation is inevitable, it should primarily serve humanity rather than the interests of trans-national corporations.", econ: 10, dipl: 0, govt: 0, scty: 0),
		Question(id: 72, "I would always support my country, whether it was right or wrong", econ: 0, dipl: -10, govt: 0, scty: 0),
		Question(id: 73, "No one chosses his or her country of birth, so it is foolish to be proud of it.", econ: 0, dipl: 10, govt: 0, scty: 5),
		Question(id: 74, "Our race has many superior qualities, compared with other races.", econ: 0, dipl: -10, govt: 0, scty: -5),
		Question(id: 75, "The enemy of my enemy is my friend.", econ: -5, dipl: -5, govt: 0, scty: 0),
		Question(id: 76, "Military action that defies international law is sometimes justified.", econ: 0, dipl: -10, govt: -5, scty: -5),
		Question(id: 77, "There is now a worrying fusion of information and entertainment.", econ: 0, dipl: 0, govt: -5, scty: -5),
		Question(id: 78, "People are ultimately divided more by class than by nationality.", econ: 5, dipl: 10, govt: 5, scty: 0),
		Question(id: 79, "Controlling inflation is more imporant that controlling unemployment.", econ: -10, dipl: 0, govt: 0, scty: 0),
		Question(id: 80, "Because corporations cannot be trusted to voluntarily protect the environment, they require regulation.", econ: 10, dipl: 0, govt: -5, scty: 0),
		Question(id: 81, "The freer the market, the freer the people.", econ: -10, dipl: 0, govt: 5, scty: 0),
		Question(id: 82, "It's a sad reflection on our society that something as basic as drinking water is now a bottled, branded consumer product.", econ: 10, dipl: 0, govt: 0, scty: 10),
		Question(id: 83, "Land shouldn't be a commodity to be bought and sold.", econ: 10, dipl: 10, govt: 5, scty: 0),
		Question(id: 84, "It is regrettable that many personal fortunes are made by people who simply manipulate money and contribute nothing to their society.", econ: 10, dipl: 0, govt: 0, scty: 0),
		Question(id: 85, "Protectionism is sometimes necessary in trade.", econ: 5, dipl: -10, govt: -5, scty: 0),
		Question(id: 86, "The only social responsibility of a company should be to deliver a profit to its shareholders.", econ: -10, dipl: 0, govt: 0, scty: 0),
		Question(id: 87, "The rich are too highly taxed.", econ: -10, dipl: 0, govt: 5, scty: -5),
		Question(id: 88, "Governments should penalise businesses that mislead the public.", econ: 5, dipl: 0, govt: -5, scty: 0),
		Question(id: 89, "A genuine free market requires restrictions on the ability of predator multinationals to create monopolies.", econ: 10, dipl: 0, govt: 0, scty: 0),
		Question(id: 90, "Abortion, when the woman's life is not threatened, should always be illegal.", econ: 0, dipl: 0, govt: -5, scty: -10),
		Question(id: 91, "All authority should be questioned.", econ: 0, dipl: 0, govt: 5, scty: 10),
		Question(id: 92, "An eye for an eye and a tooth for a tooth.", econ: 0, dipl: 0, govt: 0, scty: -10),
		Question(id: 93, "Taxpayers should not be expected to prop up any theatres or museums that cannot survive on a commercial basis.", econ: -5, dipl: 0, govt: 0, scty: -5),
		Question(id: 94, "Schools should not make classroom attendance compulsory.", econ: 0, dipl: 0, govt: 10, scty: 5),
		Question(id: 95, "All people have their rights, but it is better for all of us that different sorts of people should keep to their own kind.", econ: 0, dipl: -5, govt: 0, scty: -10),
		Question(id: 96, "Good parents sometimes have to spank their children.", econ: 0, dipl: 0, govt: 0, scty: -5),
		Question(id: 97, "It's natural for children to keep some secrets from their parents.", econ: 0, dipl: 0, govt: 0, scty: 5),
		Question(id: 98, "Possessing marijuana for personal use should not be a criminal offence.", econ: 0, dipl: 0, govt: 10, scty: 10),
		Question(id: 99, "The most important thing for children to learn id to accept discipline.", econ: 0, dipl: 0, govt: 0, scty: -10),
		Question(id: 100, "The prime function of schooling should be to equip the future generation to find jobs.", econ: -5, dipl: 0, govt: 0, scty: -5),
		Question(id: 101, "People with serious inheritable disabilities should not be allowed to reproduce.", econ: 0, dipl: 0, govt: -10, scty: -10),
		Question(id: 102, "The are no savage and civilised peoples; there are only different cultures.", econ: 0, dipl: 10, govt: 0, scty: 10),
		Question(id: 103, "Those who are able to work, and refuse the opportunity, should not expect society's support.", econ: -10, dipl: 0, govt: 0, scty: -5),
		Question(id: 104, "When you are troubled, it's better not to think about it, but to keep busy with more cheerful things.", econ: 0, dipl: 0, govt: 0, scty: -5),
		Question(id: 105, "First-generation immigrants can never be fully integrated within their new country.", econ: 0, dipl: -5, govt: 0, scty: -5),
		Question(id: 106, "What's good for the most successful corporations is always, ultimately, good for all of us.", econ: -5, dipl: 0, govt: 0, scty: 5),
		Question(id: 107, "No broadcasting institution, however independent its content, should receive public funding.", econ: 0, dipl: 0, govt: -5, scty: -10),
		Question(id: 108, "Our civil liberties are being excessively curbed in the name of counter-terrorism.", econ: 0, dipl: 0, govt: 10, scty: 0),
		Question(id: 109, "A significant advantage of a one-party state is that it avoids all the arguments that delay progress in a democratic political system.", econ: 0, dipl: 0, govt: -10, scty: 0),
		Question(id: 110, "Although the digital age makes official surveillance easier, only wrongdoers need to be worried.", econ: 0, dipl: 0, govt: -10, scty: 0),
		Question(id: 111, "The death penalty should be an option for the most serious crimes.", econ: 0, dipl: 0, govt: -10, scty: -10),
		Question(id: 112, "In a civilised society, there should always exist a social hierarchy.", econ: 0, dipl: 0, govt: -10, scty: -5),
		Question(id: 113, "Abstract art shouldn't be considered art.", econ: 0, dipl: 0, govt: -5, scty: -5),
		Question(id: 114, "In the criminal justice system, we should give more importance to punishment rather than rehabilitation.", econ: 0, dipl: 0, govt: -10, scty: -10),
		Question(id: 115, "Rehabilitation of criminals is a waste of time.", econ: 0, dipl: 0, govt: -10, scty: -5),
		Question(id: 116, "STEM careers are more important than the humanities.", econ: -10, dipl: 0, govt: -5, scty: -5),
		Question(id: 117, "Women may have careers, but their first duty is to the husband and families.", econ: 0, dipl: 0, govt: 0, scty: -10),
		Question(id: 118, "Multinational companies are unethically explointing the resources of developing countries.", econ: 5, dipl: 5, govt: 5, scty: 5),
		Question(id: 119, "Making peace with the authority figures is a key aspect of maturity.", econ: 0, dipl: 0, govt: -5, scty: -5),
		Question(id: 120, "The esoteric realm can explain things that science cannot.", econ: 0, dipl: 0, govt: 0, scty: -5),
		Question(id: 121, "You cannot be moral if you don't follow a religion.", econ: 0, dipl: 0, govt: 0, scty: -10),
		Question(id: 122, "Charity is better than social programmes to help the genuinely disadvantaged.", econ: -5, dipl: 0, govt: 0, scty: -5),
		Question(id: 123, "It is important that my child's school instills religious values.", econ: 0, dipl: 0, govt: 0, scty: -10),
		Question(id: 124, "Same sex couples, if they fill all other criteria, should not be excluded from the possibility of child adoption.", econ: 0, dipl: 0, govt: 10, scty: 10),
		Question(id: 125, "Pornography, depicting consenting adults, should be legal for adult consumption.", econ: 0, dipl: 0, govt: 10, scty: 10),
		Question(id: 126, "What happens in a private space between consenting adults is no business of any governing body.", econ: 0, dipl: 0, govt: 10, scty: 10),
		Question(id: 127, "No one is naturally homosexual.", econ: 0, dipl: 0, govt: -5, scty: -10),
    ]
    
    
}
