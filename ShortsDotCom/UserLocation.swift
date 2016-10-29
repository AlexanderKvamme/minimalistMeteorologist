//
//  Location.swift
//  LocationFinderExtreme
//
//  Created by Alexander Kvamme on 11/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation
import CoreLocation

// Singleton class Location:
// - Includes all location related functionality across app

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    // variables
    
    var latitude: Double?
    var longitude: Double?
    let locationManager = CLLocationManager()
    
    // geoCoder
    
    var geoCoder: CLGeocoder?
    var country = ""
    var locality = ""
    var locationName: String {
        if country != "" {
        return "in \(locality), \(country)"
        }
        else {return ""}
    }
    
    
    // Singleton
    
    static let sharedInstance = UserLocation()
    
    // Init
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        geoCoder = CLGeocoder()
    }

    // Content
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        self.latitude = center.latitude
        self.longitude = center.longitude
        
        // Use received location for finding "Country, City"
        self.startReverseGeocoding(CLLocation(latitude: center.latitude, longitude: center.longitude))
        
        // post notification
        NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.userLocationGPSDidUpdate), object: self)
        
    }
    
    // Update function
    
    func updateLocation(){
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager failed, returning error: \"\(error)\"")
    }
    
    
    // Task: - Reverse Geocoder
    
    func startReverseGeocoding(_ location: CLLocation){
        
        geoCoder?.reverseGeocodeLocation(location, completionHandler: { (placemark, error) in
            
            if error != nil{
                // TASK: - TODO error message to screen
                print("error in startReverseGeocoding:", error?.localizedDescription)
                return
            }
            
            if let lastMark = placemark?.last{
                
                //print("\nLast registered placemark:\n \(lastMark) \n")
                
                self.country = lastMark.country!
                self.locality = lastMark.locality!
                print("country: \(self.country)")
                print("locality: \(self.locality)")
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: self)
                
            }
        })
    }
    
    
    
    
    
}
