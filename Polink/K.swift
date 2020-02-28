//
//  K.swift
//  Polink
//
//  Created by Jose Saldana on 03/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation

struct K {
    static let appName = "🗣 Polink"
    
    struct Popup {
        static let signUpError = "Sign up Failed"
        static let signInError = "Sign in Failed"
    }
    
    struct Segue {
        static let signupToRegistration = "signupToRegistration"
        static let loginToTab = "loginToTab"
        static let loginToRegistration = "loginToRegistration"
        static let registrationToQuiz = "registrationToQuiz"
        static let quizToTab = "quizToTab"
        static let firstToRegister = "firstToRegister"
        static let firstToLogin = "firstToLogin"
    }
    struct ideologyAxes {
        static let econ = "Economy"
        static let dipl = "Diplomacy"
        static let govt = "Government"
        static let scty = "Society"
    }
    struct answerStrength {
        static let stronglyAgree = "Strongly Agree"
        static let agree = "Agree"
        static let neutralUnsure = "Neutral / Unsure"
        static let disagree = "Disagree"
        static let stronglyDisagree = "Strongly Disagree"
    }
    struct userGenders {
        static let male = "Male"
        static let female = "Female"
        static let trans = "Transgender"
        static let other = "Other"
    }
    struct regPages {
        static let pageOne = "PageOneCompleted"
        static let pageTwo = "PageTwoCompleted"
        static let pageThree = "PageThreeCompleted"
    }
}
