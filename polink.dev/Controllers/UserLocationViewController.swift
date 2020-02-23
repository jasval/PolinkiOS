//
//  UserLocationViewController.swift
//  polink.dev
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
    @IBOutlet weak var searchBar: UITextField!
    
    var userInfo = UserInformation()
    let manager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        mapView.alpha = 0
        
    }
    override func viewDidAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (Timer) in
            self.manager.requestWhenInUseAuthorization()
            self.manager.delegate = self
        }
    }
    
    @IBAction func searchCompleted(_ sender: Any) {
        if let searchTerms = searchBar.text {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(searchTerms) { (clPlacemark, Error) in
                
            }
        }
    }
    @IBAction func locateDevice(){
        manager.requestLocation()
        // Setting the default map coordinates for the device

        let location = CLLocationCoordinate2DMake(userInfo.location?.latitude ?? 0, userInfo.location?.longitude ?? 0)
        let annotation = MKPointAnnotation()
        initialiseMap(location)
        initialiseAnnotation(annotation, location: location)

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
// MARK: Core Location and Mapkit methods

extension UserLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            userInfo.writeLocation(geoPoint)
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, preferredLocale: .current) { (placemark, Error) in
                if let geoLoc = placemark!.first {
                    self.userInfo.writegeoLoc(geoLoc.country!, geoLocCity: geoLoc.locality!)
                } else {
                    print("Program threw an error geocoding localisation: \(Error!.localizedDescription)")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func initialiseMap(_ location: CLLocationCoordinate2D) {
         // Set default span of the MapKit View
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
         // Setting default region of the map to show based on coordinates and span
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        if mapView.alpha == 0 {
            animateIn(mapView, delay: 0.5)
        }

     }
     func initialiseAnnotation(_ annotation: MKPointAnnotation, location: CLLocationCoordinate2D) {
         // Set annotation coordinates for the center of the region
         annotation.coordinate = location
         annotation.title = "Big Ben"
         annotation.subtitle = "London"
         mapView.addAnnotation(annotation)
     }
     
}
