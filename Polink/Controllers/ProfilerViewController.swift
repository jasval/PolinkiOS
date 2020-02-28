//
//  ProfilerViewController.swift
//  Polink
//
//  Created by Jose Saldana on 01/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfilerViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quizProgress: UIProgressView!
    @IBOutlet var buttons: [UIButton]! = []
    @IBOutlet weak var quizLabel: UILabel!
    @IBOutlet weak var answerStack: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    
    //      Creating an instance of the QuizBrain
    var quiz = QuizBrain()
        
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //      Progress Bar Styling and Initialisation
        
        quizProgress.progress = 0
        quizProgress.transform = quizProgress.transform.scaledBy(x: 1, y: 4)
        quizProgress.layer.masksToBounds = true
        quizProgress.layer.cornerRadius = quizProgress.frame.height / 2
        quizProgress.alpha = 0
        
        //      Creating the Answer Buttons
        
        for i in 1...5 {
            let button = AnswerButton(position: i)
            answerStack.addArrangedSubview(button)
            button.addTarget(self, action: #selector(answerButtonPressed(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        //      Initialising the back button
        backButton.layer.masksToBounds = true
        backButton.layer.cornerRadius = backButton.frame.height / 5
        backButton.alpha = 0
        
        
        //      Set up initial labels
        
        titleLabel.text = "Hello, \(UserDS.user.fname ?? "New User")"
        titleLabel.alpha = 0.0
        quizLabel.text = "We are going to ask you a few quetions so we can get to know you better. \nThere are no right or wrong answers, and how truthfully you respond to each statement will reflect on your personal experience."
        quizLabel.alpha = 0
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 2) {
            self.titleLabel.alpha = 1
        }
        UIView.animate(withDuration: 2, delay: 0.5, animations: {
            self.quizLabel.alpha = 1
        }, completion: nil)
        
        Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { (Timer) in
            UIView.animate(withDuration: 2, animations: {
                self.titleLabel.alpha = 0
                self.quizLabel.alpha = 0
            }, completion: nil)
        }
        Timer.scheduledTimer(withTimeInterval: 9, repeats: false, block: {(Timer) in
            self.startQuiz()
        })
        
    }
    
    @IBAction func answerButtonPressed(_ sender: AnswerButton){
        quiz.nextQuestion(sender.effect!)
        loadQuestion()
        updateProgressBar()
    }
    
    func startQuiz () {
        quiz.initQuiz()
        loadQuestion()
        var delayCounter:Double = 1
        for button in buttons {
            animateIn(button, delay: 1 + delayCounter)
            //            UIView.animate(withDuration: 1, delay: 1 + delayCounter, animations: {
            //                button.alpha = 1
            //            }, completion: nil)
            delayCounter += 0.5
        }
        animateIn(quizProgress, delay: 5)
        //        UIView.animate(withDuration: 1, delay: 5, options: .curveLinear, animations: {
        //            self.quizProgress.alpha = 1
        //        }, completion: nil)
        animateIn(backButton, delay: 6)
        
    }
    
    func loadQuestion() {
        animateOutQ()
        if quiz.questionNo < quiz.quizList.count {
            quizLabel.text = quiz.quizList[quiz.questionNo].prompt
            titleLabel.text = "Question: \(quiz.questionNo + 1)"
            animateInQ()
        } else {
            print("End of questions")
            print("Max diplomacy score is \(quiz.maxDipl)")
            print("Your raw diplomacy score is: \(quiz.dipl)")
            print("Your calculated diplomacy score is: \(quiz.calcScores(quiz.dipl, maxScore: quiz.maxDipl))")
            print("Max economy score is \(quiz.maxEcon)")
            print("Your economy score is: \(quiz.econ)")
            print("Your calculated economy score is: \(quiz.calcScores(quiz.econ, maxScore: quiz.maxEcon))")
            print("Max government score is: \(quiz.maxGovt)")
            print("Your government score is: \(quiz.govt)")
            print("Your calculated government score is: \(quiz.calcScores(quiz.govt, maxScore: quiz.maxGovt))")
            print("Max societal score is: \(quiz.maxScty)")
            print("Your societal score is: \(quiz.scty)")
            print("Your calculated societal score is: \(quiz.calcScores(quiz.scty, maxScore: quiz.maxScty))")
            for button in buttons {
                animateOut(button)
            }
            animateOut(quizProgress)
            recordResults()
            print(UserDS.user.polinkIdeology)
            displayResults()
            displayNextButton()
        }
        
    }
    
    func displayResults(){
        let resultsLabel = UILabel()
        self.view.addSubview(resultsLabel)
        resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        resultsLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        resultsLabel.heightAnchor.constraint(equalToConstant: 300).isActive = true
        resultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        resultsLabel.textAlignment = NSTextAlignment.center
        resultsLabel.numberOfLines = 0
        resultsLabel.alpha = 0
        resultsLabel.text = "Diplomacy Score: \(UserDS.user.polinkIdeology[K.ideologyAxes.dipl] ?? 0)\nEconomy Score: \(UserDS.user.polinkIdeology[K.ideologyAxes.econ] ?? 0)\nGovernment Score: \(UserDS.user.polinkIdeology[K.ideologyAxes.govt] ?? 0)\nSociety Score: \(UserDS.user.polinkIdeology[K.ideologyAxes.scty] ?? 0)"
        animateIn(resultsLabel, delay: 1)
    }
    func displayNextButton() {
        let nextButton = UIButton(type: .roundedRect)
        nextButton.backgroundColor = UIColor.gray
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.alpha = 0
        self.view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nextButton.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
        animateIn(nextButton, delay: 3)
    }
    func recordResults() {
        UserDS.user.polinkIdeology[K.ideologyAxes.dipl] = quiz.calcScores(quiz.dipl, maxScore: quiz.maxDipl)
        UserDS.user.polinkIdeology[K.ideologyAxes.econ] = quiz.calcScores(quiz.econ, maxScore: quiz.maxEcon)
        UserDS.user.polinkIdeology[K.ideologyAxes.govt] = quiz.calcScores(quiz.govt, maxScore: quiz.maxGovt)
        UserDS.user.polinkIdeology[K.ideologyAxes.scty] = quiz.calcScores(quiz.scty, maxScore: quiz.maxScty)
    }
    func sendResults() {
        let uid = Auth.auth().currentUser?.uid
        let email =  Auth.auth().currentUser?.email
        if let uid = uid, let email = email {
            let userR = UserDataModel(uid, firstname: UserDS.user.fname!, lastname: UserDS.user.lname!, email: email, dob: UserDS.user.dob!, gender: UserDS.user.gender!, ideology: UserDS.user.polinkIdeology, location: UserDS.user.location!, country: UserDS.user.geoLocCountry!, city: UserDS.user.geoLocCity!)
            do {
                try db.collection("users").document("\(uid)").setData(from: userR)
            } catch let error {
                print("Error writing data to the database: \(error.localizedDescription)")
                displayRetryButton()
                return
            }
        }
    }
    @IBAction func nextButtonPressed(_ sender: UIButton){
        self.performSegue(withIdentifier: K.Segue.quizToTab, sender: self)
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
    }
    @IBAction func retryButtonPressed(_ sender: UIButton){
        sendResults()
    }
    func animateInQ() {
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveLinear, animations: {
            self.quizLabel.alpha = 1
            self.titleLabel.alpha = 1
        }, completion: nil)
    }
    
    func animateOutQ() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.quizLabel.alpha = 0
            self.titleLabel.alpha = 0
        }, completion: nil)
    }
    func updateProgressBar () {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.quizProgress.setProgress(self.quiz.getProgress(), animated: true)
        }, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    func displayRetryButton() {
        let retryButton = UIButton(type: .custom)
        self.view.addSubview(retryButton)
        retryButton.alpha = 0
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setTitleColor(UIColor.white, for: .normal)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        retryButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        retryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 40).isActive = true
        retryButton.addTarget(self, action: #selector(retryButtonPressed(_:)), for: .touchUpInside)
        animateIn(retryButton, delay: 0)
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

