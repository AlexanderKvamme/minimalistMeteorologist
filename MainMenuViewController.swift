//
//  MainMenuViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 24/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreLocation

class MainMenuViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reverseGeocodeHandler), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        updateExtendedCurrentWeatherTest()
        UserLocation.sharedInstance.updateLocation() 
    }

    func updateExtendedCurrentWeatherTest(){
        
        forecastClient.fetchExtendedCurrentWeather(currentCoordinate) { apiresult in
            
            //self.activityIndicator.startAnimating()
            
            switch apiresult{
                
            case .success(let extendedCurrentWeather):
                
                //self.activityIndicator.stopAnimating()
                
                print("fetch of extended weather request SUCCESSFUL")
                //print(extendedCurrentWeather)
                
                //Animations.playCheckmarkAnimationOnce(inImageView: self.animationView)
             
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                //self.activityIndicator.stopAnimating()
                
                showAlert(viewController: self, title: "Error", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
                
            default: break
            }
        }
    }

    
    func settingsDidUpdate(){
        print("*playing update animation*")
    }

    
    func reverseGeocodeHandler(){
        
        if let latestGPS = UserLocation.sharedInstance.coordinate{
            
            currentCoordinate = latestGPS
        
        } else {
            showAlert(viewController: self, title: "Error fetching gps", message: "We can fetch weather for you if you let us access Location Services. Please enable Location Services in your settings and restart the app to update GPS.", error: nil)
        }
    }
}
