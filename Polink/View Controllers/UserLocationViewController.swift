//
//  UserLocationViewController.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class UserLocationViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var nextArrow: UIButton!
    
    let manager = CLLocationManager()
    var location: CLLocation?
    
    // Flag to account for latency in GPS and network response
    var isUpdatingLocation = false
    var lastLocationError: Error?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("\(String(describing: Registration.state.fname)) and \(String(describing: Registration.state.gender))")
    }
    
//    @IBAction func searchCompleted(_ sender: Any) {
//        if let searchTerms = searchBar.text {
//            let geoCoder = CLGeocoder()
//            geoCoder.geocodeAddressString(searchTerms) { (clPlacemark, error) in
//                if let place = clPlacemark!.first {
//                    if let country = place.country, let city = place.locality {
//                        UserDS.user.writegeoLoc(country, geoLocCity: city)
//                        let geoPoint = GeoPoint(latitude: place.location!.coordinate.latitude, longitude: place.location!.coordinate.longitude)
//                        UserDS.user.writeLocation(geoPoint)
//                        let location = CLLocationCoordinate2DMake(UserDS.user.location!.latitude, UserDS.user.location!.longitude)
//                        let annotation = MKPointAnnotation()
//                        self.initialiseMap(location)
//                        self.initialiseAnnotation(annotation, location: location)
//                    } else {
//                        print("City or/and Country could not be found: \(error!.localizedDescription)")
//                    }
//
//                } else {
//                    print("There has been an error: \(error!.localizedDescription)")
//                }
//            }
//        }
//        resignFirstResponder()
//    }
    
    func updateUI() {
        if let location = location {
            // TODO: populate the location map with coordinate info
            recordUserLocation(location)
            initialiseMap(location.coordinate)
            checkIfComplete()
//            initialiseAnnotation(location: location.coordinate)
        } else {
            mapView.alpha = 0
            checkMark.alpha = 0
        }
    }

    // MARK: - Target / Action
    
    @IBAction func locateButtonPressed(_ sender: UIButton){
        // 1. get the user's permission to use location services
        sender.pulsate()
        let authorisationStatus = CLLocationManager.authorizationStatus()
        if authorisationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
            return
        }
        
        // 2. report to user if permission is denied - (1) user accidentally refused (2) the device is restricted
        if authorisationStatus == .denied || authorisationStatus == .restricted {
            reportLocationServicesDeniedError()
            return
        }
        
        // 3. start / stop finding location
        if isUpdatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
//        updateUI()
        
//        locateButton.pulsate()
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.semaphore.wait()
//            self.manager.requestLocation()
//        }
//        if let loc = UserDS.user.location {
//            print(loc)
//        } else {
//            print("nothing was written here")
//        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.semaphore.wait()
//            let location = CLLocationCoordinate2DMake(UserDS.user.location!.latitude, UserDS.user.location!.longitude)
//            let annotation = MKPointAnnotation()
//            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (Timer) in
//            }
//            DispatchQueue.main.async {
//                self.updateUI(location, annotation: annotation)
//                self.semaphore.signal()
//            }
//        }
    }
    
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            // We don't require accuracy as we are trying to determine if the peole are in the same country or not.
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            manager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }
    
    func stopLocationManager() {
        if isUpdatingLocation {
            manager.stopUpdatingLocation()
            manager.delegate = nil
            isUpdatingLocation = false
        }
    }
    
    func reportLocationServicesDeniedError() {
        // Create alert and action to present to the user in case location services is disabled
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please go to Settings > Privacy to enable location services for this app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok!", style: .default, handler: nil)
        
        // Add action to the alert.
        alert.addAction(okAction)
        
        // Present the alert to the user
        present(alert, animated: true, completion: nil)
        
    }
    
//
//    func updateUI(_ location: CLLocationCoordinate2D, annotation: MKPointAnnotation) {
//        self.checkIfComplete()
//        self.initialiseMap(location)
//        self.initialiseAnnotation(annotation, location: location)
//    }
    
    func recordUserLocation(_ location: CLLocation) {
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        Registration.state.location = geoPoint
        print(Registration.state.location ?? "None")
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, preferredLocale: .current) { (placemark, Error) in
            if let geoLoc = placemark!.first {
                let country = geoLoc.country
                let city = geoLoc.locality
                Registration.state.geoLocCity = city
                Registration.state.geoLocCountry = country
                print("\(Registration.state.geoLocCountry ?? "No Country") and \(Registration.state.geoLocCity ?? "No City")")
            } else {
                print("Program threw an error geocoding localisation: \(Error!.localizedDescription)")
            }
        }
    }
    
    
    func checkIfComplete() {
        if Registration.state.location != nil && Registration.state.geoLocCity != nil && Registration.state.geoLocCountry != nil{
            animateIn(checkMark, delay: 0.5)
            Registration.state.regCompletion[2] = true
        } else {
            if checkMark.alpha > 0 {
                animateOut(checkMark)
                Registration.state.regCompletion[2] = false
            }
            return
        }
    }
}


// MARK: Core Location and Mapkit methods
// If we want to implement a set of methods is better to set up an extension to organise your code.

extension UserLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            // this is not a system error and as such we should just return
            return
        }
        // if it is a system error
        lastLocationError = error
        stopLocationManager()
        updateUI()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // retrieves the last element of the array of stored locations -- a more accurate result
        location = locations.last!
        print("Location manager did update locations: \(String(describing: location))")
        updateUI()
//        if let location = locations.first {
//            print("Found user's location: \(location)")
//            let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            UserDS.user.writeLocation(geoPoint)
//            print(UserDS.user.location ?? "None")
//            let geoCoder = CLGeocoder()
//            geoCoder.reverseGeocodeLocation(location, preferredLocale: .current) { (placemark, Error) in
//                if let geoLoc = placemark!.first {
//                    let country = geoLoc.country
//                    let city = geoLoc.locality
//                    UserDS.user.writegeoLoc(country!, geoLocCity: city!)
//                    print("\(UserDS.user.geoLocCountry ?? "No Country") and \(UserDS.user.geoLocCity ?? "No City")")
//                } else {
//                    print("Program threw an error geocoding localisation: \(Error!.localizedDescription)")
//                }
//            }
//        }
//        self.semaphore.signal()
    }
    

    func initialiseMap(_ locationCenter: CLLocationCoordinate2D) {
        // Set default span of the MapKit View
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        // Setting default region of the map to show based on coordinates and span
        let region = MKCoordinateRegion(center: locationCenter, span: span)
        mapView.setRegion(region, animated: true)
        
        if mapView.alpha == 0 {
            animateIn(mapView, delay: 0.5)
        }
        
    }
    
//    func initialiseAnnotation(location: CLLocationCoordinate2D) {
//        // Set annotation coordinates for the center of the region
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        annotation.title = UserDS.user.geoLocCity
//        annotation.subtitle = UserDS.user.geoLocCountry
//        mapView.addAnnotation(annotation)
//    }
    
}
