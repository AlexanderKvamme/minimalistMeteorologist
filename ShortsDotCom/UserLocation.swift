

import Foundation
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    var latitude: Double?
    var longitude: Double?
    var coordinate: Coordinate?
    let locationManager = CLLocationManager()
    
    // Geocoder
    
    var geoCoder: CLGeocoder?
    var country = ""
    var locality = ""
    var subLocality = ""
    var administrativeArea = ""
    var locationName: String {
        if country != "" {
        return "in \(locality), \(country)"
        }
        else {return ""}
    }
    
    // Singleton
    
    static let sharedInstance = UserLocation()
    
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
        self.coordinate = Coordinate(lat: center.latitude, lon: center.longitude)
        
        // Use received location for finding "Country, City"
        self.startReverseGeocoding(CLLocation(latitude: center.latitude, longitude: center.longitude))
        
        // post notification
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.userLocationGPSDidUpdate), object: self)
    }
    
    // Update function
    
    func updateLocation(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.locationManagerFailed), object: self)
        print("locationManager failed. Enable Location services.")
    }
    
    // Task: - Reverse Geocoder
    
    func startReverseGeocoding(_ location: CLLocation){
        geoCoder?.reverseGeocodeLocation(location, completionHandler: { (placemark, error) in
            
            if error != nil{
                print("error found. returning")
                return
            }
            
            if let lastMark = placemark?.last{
                
                self.printPlacemark(lastMark)
                
                // unwrap
                if let country = lastMark.country {
                    self.country = country
                }
                if let locality = lastMark.locality {
                    self.locality = locality
                }
                //self.country = lastMark.country!
                //self.locality = lastMark.locality!
                if let subLocality = lastMark.subLocality {
                    self.subLocality = subLocality
                }
                //self.subLocality = lastMark.subLocality!
                
                if let adminArea = lastMark.administrativeArea {
                    self.administrativeArea = adminArea
                }
                //self.administrativeArea = lastMark.administrativeArea!
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.reverseGeocodingDidFinish), object: self)
            }
        })
    }
    
    // MARK: - Helper methods
    
    func printPlacemark(_ placemark: CLPlacemark) {
        print()
        print("country: ", placemark.country as Any)
        print("locality: ", placemark.locality as Any)
        print("isoCountryCode: ", placemark.isoCountryCode as Any)
        //print("location: ", placemark.location as Any) // CLLocation radius
        print("name: ", placemark.name as Any)
        print(placemark.areasOfInterest)
        //print("region: ", placemark.region as Any) eCLCircualrRegion
        if placemark.subAdministrativeArea != nil {
                print("subAdmininstrative area:", placemark.subAdministrativeArea as Any)
        }
        print("Admininstrative area:", placemark.administrativeArea as Any)
        print("sublocality:", placemark.subLocality as Any)
        //print("postalCode:" ,placemark.postalCode as Any)
        //print("subThoroughfare: ", placemark.subThoroughfare as Any)
        print()
    }
}

