//
//  LocationVC.swift
//  Polink
//
//  Created by Jose Saldana on 16/02/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class LocationVC: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var nextArrow: UIButton!
	@IBOutlet weak var locateButton: UIButton!
	
    let manager = CLLocationManager()
    var location: CLLocation?
    
    // Flag to account for latency in GPS and network response
    var isUpdatingLocation = false
    var lastLocationError: Error?
	let authorisationStatus = CLLocationManager.authorizationStatus()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
		nextArrow.isUserInteractionEnabled = true
		nextArrow.addTarget(self, action: #selector(didPressNext), for: .touchUpInside)
		mapView.layer.cornerRadius = 15

    }
    override func viewDidAppear(_ animated: Bool) {
        print("\(String(describing: Registration.state.fname)) and \(String(describing: Registration.state.gender))")
		if authorisationStatus == .notDetermined {
			manager.requestWhenInUseAuthorization()
			return
		}
    }
    
    func updateUI() {
        if let location = location {
            // TODO: populate the location map with coordinate info
            recordUserLocation(location)
//            initialiseMap(location.coordinate)
//            checkIfComplete()
        } else {
            mapView.alpha = 0
            checkMark.alpha = 0
			nextArrow.alpha = 0
        }
    }

    // MARK: - Target / Action
    
    @IBAction func locateButtonPressed(_ sender: UIButton){
        // 1. get the user's permission to use location services
        sender.pulsate()

        // 2. report to user if permission is denied - (1) user accidentally refused (2) the device is restricted
        if authorisationStatus == .denied || authorisationStatus == .restricted {
            reportLocationServicesDeniedError()
            return
        }
        
		location = nil
		lastLocationError = nil
		startLocationManager()

    }
    
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            manager.delegate = self
            // We don't require accuracy as we are trying to determine if the people are in the same country or not.
            manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            manager.startUpdatingLocation()
			locateButton.isEnabled = false
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

    func recordUserLocation(_ location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_GB")) { [weak self] (placemark, Error) in
            if let geoLoc = placemark!.first {
                let country = geoLoc.country
                let city = geoLoc.locality
                Registration.state.geoLocCity = city
                Registration.state.geoLocCountry = country
                print("\(Registration.state.geoLocCountry ?? "No Country") and \(Registration.state.geoLocCity ?? "No City")")
				self?.locateButton.isEnabled = true
				self?.initialiseMap(location.coordinate)
            } else {
                print("Program threw an error geocoding localisation: \(Error!.localizedDescription)")
				self?.locateButton.isEnabled = true
            }
        }
    }
    
    
    func checkIfComplete() {
        // Registration.state.location != nil && 
        if Registration.state.geoLocCity != nil && Registration.state.geoLocCountry != nil{
            animateIn(checkMark, delay: 0.5)
			animateIn(nextArrow, delay: 0.5)
            Registration.state.regCompletion[2] = true
			nextArrow.shake()
        } else {
            if checkMark.alpha > 0 {
                animateOut(checkMark)
                Registration.state.regCompletion[2] = false
            }
            return
        }
    }
	
	@objc func didPressNext() {
		print("it is registering the tap")
		// get parent view controller
		let parentVC = self.parent as! PageNavController
		
		// change page of PageViewController
		parentVC.setViewControllers([parentVC.viewControllerList[3]], direction: .forward, animated: true, completion: nil)
	}
}


// MARK: Core Location and Mapkit methods
// If we want to implement a set of methods is better to set up an extension to organise your code.

extension LocationVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            // this is not a system error and as such we should just return
            return
        }
        // System error
        lastLocationError = error
        stopLocationManager()
        updateUI()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // retrieves the last element of the array of stored locations -- a more accurate result
        location = locations.last!
        print("Location manager did update locations: \(String(describing: location))")
        updateUI()
		stopLocationManager()
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
		checkIfComplete()
    }
	
}
