//
//  RegistrationUserViewModel.swift
//  Polink
//
//  Created by Jasper Valdivia on 17/10/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import Foundation
import CoreLocation

class RegistrationUserViewModel {
    
    enum RegistrationError: Error {
        case failedRegistering
        case invalidInput
        case invalidNameLength
        case profaneName
        case tooYoung
        case tooOld
        case invalidCity
        case invalidCountry
        case incompleteFields
        
        public var errorDescription: String? {
            switch self {
            case .failedRegistering:
                return LocalizedString("error_registration_failed")
            case .invalidInput:
                return LocalizedString("error_registration_invalidInput")
            case .invalidNameLength:
                return LocalizedString("error_registration_nameLength")
            case .profaneName:
                return LocalizedString("error_registration_profaneName")
            case .tooYoung:
                return LocalizedString("error_registration_dob_young")
            case .tooOld:
                return LocalizedString("error_registration_dob_old")
            case .invalidCity:
                return LocalizedString("error_registration_city")
            case .invalidCountry:
                return LocalizedString("error_registration_country")
            case .incompleteFields:
                return LocalizedString("error_registration_incomplete")
            }
        }
    }
    
    private var dateBoundaries: (Date, Date) {
        let calendar = Calendar.current
        let currentDate = Date()
        var components = DateComponents(calendar: calendar)
        
        components.year = -18
        
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -150
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        return (minDate, maxDate)
    }
    
    private var user: UserDataModel
    
    private var firstName: String? {
        didSet {
            user.firstName = firstName
        }
    }
    private var lastName: String? {
        didSet {
            user.lastName = lastName
        }
    }
    private var email: String {
        get {
            user.email
        }
    }
    private var dateOfBirth: Date? {
        didSet {
            user.dob = dateOfBirth
        }
    }
    private var gender: UserDataModel.Gender? {
        didSet {
            user.gender = gender
        }
    }
    private var city: String? {
        didSet {
            user.city = city
        }
    }
    private var country: String? {
        didSet {
            user.country = country
        }
    }
    
    init(_ user: UserDataModel) {
        self.user = user
    }
    
    
    enum NameType {
        case firstName
        case lastName
    }
    
    func updateName(_ name: String?, type: NameType) -> Result<Any, RegistrationError> {
        guard let name = name else {return .failure(.invalidInput)}
        guard !name.containsBadWords() else {return .failure(.profaneName)}
        guard name.count >= 2 && name.count < 20 else {return .failure(.invalidNameLength)}
        
        switch type {
        case .firstName:
            firstName = name
            if user.firstName == name {
                return .success(name)
            } else {
                return .failure(.failedRegistering)
            }
        case .lastName:
            lastName = name
            if user.lastName == name {
                return .success(name)
            } else {
                return .failure(.failedRegistering)
            }
        }
    }
    
    func updateDateOfBirth(_ date: Date?) -> Result<Any, RegistrationError> {
        guard let date = date else {return .failure(.invalidInput)}
        let boundary = dateBoundaries
        guard date < boundary.0 else {return .failure(.tooYoung)}
        guard date > boundary.1 else {return .failure(.tooOld)}
        
        dateOfBirth = date
        if user.dob == date {
            return .success(date)
        } else {
            return .failure(.failedRegistering)
        }
    }
    
    func updateGender(_ gender: UserDataModel.Gender?) -> Result<Any, RegistrationError> {
        guard let gender = gender else { return .failure(.invalidInput)}        
        self.gender = gender
        
        if user.gender == gender {
            return .success(gender)
        } else {
            return .failure(.failedRegistering)
        }
    }
    
    func updateLocation(_ location: CLLocation?) -> Result<Any, RegistrationError> {
        guard let location = location else { return .failure(.invalidInput)}
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_GB")) { [weak self] (placemark, error) in
            if let geoLoc = placemark!.first {
                self?.country = geoLoc.country
                self?.city = geoLoc.locality
            }
        }
        if user.country == country && user.city == city {
            return .success((country, city))
        } else {
            return .failure(.failedRegistering)
        }
    }
    
}
