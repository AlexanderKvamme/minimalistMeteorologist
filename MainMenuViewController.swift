//
//  MainMenuViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 24/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreLocation

var latestExtendedWeatherFetched: ExtendedCurrentWeather? = nil

class MainMenuViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkmarkView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {
        print("unWindToMainMenu()")
    }
    
    var isFetching = false
    
    // ViewDidLoad
    
    override func viewDidLoad() {
        
        print("vdl starter med isFetchint:", isFetching)
        
        super.viewDidLoad()
        
        setUserDefaultsIfInitialRun()
        
        buttonStack.isUserInteractionEnabled = false
        activityIndicator.isHidden = true
        
        todayButton.layer.borderWidth = 2
        todayButton.layer.borderColor = UIColor.black.cgColor
        
        // Set observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reverseGeocodeHandler), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notifications.fetchCurrentWeatherDidFail), object: nil, queue: nil) {
            notification in
            
            if self.presentedViewController == nil {
                showAlert(viewController: self, title: "Server denied fetch", message: "Please try again later", error: nil)
            }
        }
        
        
        // willAllowLocationServices test
        UserDefaults.standard.synchronize()
        print("tester om vi har allowed: ", UserDefaults.standard.bool(forKey: "willAllowLocationServices"))
        if UserDefaults.standard.bool(forKey: "willAllowLocationServices") == true{
            
            UserLocation.sharedInstance.updateLocation()
        } else {
            
            toggleLoadingMode(true)
            isFetching = false
            activityIndicator.isHidden = true
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // TOOO
        print("vda")
        UIApplication.shared.keyWindow?.rootViewController = self
    }

    // Data
    
    func toggleLoadingMode(_ status: Bool){
    
        switch status{
        
        case true:
            self.isFetching = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            
            self.buttonStack.alpha = 0.4
            self.settingsButton.alpha = 0.4
            self.buttonStack.isUserInteractionEnabled = false
            self.settingsButton.isUserInteractionEnabled = false
        
        default:
            
            self.isFetching = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
            self.buttonStack.alpha = 1
            self.settingsButton.alpha = 1
            self.buttonStack.isUserInteractionEnabled = true
            self.settingsButton.isUserInteractionEnabled = true
            
            Animations.playCheckmarkAnimationOnce(inImageView: self.checkmarkView)
        }
    }
    
    //override func viewDidAppear(_ animated: Bool) {
        //
    //}
    
    func updateExtendedCurrentWeather(){
        
        toggleLoadingMode(true)
        
        forecastClient.fetchExtendedCurrentWeather(currentCoordinate) { apiresult in
            
            self.toggleLoadingMode(false)
            
            switch apiresult{
                
            case .success(let result):
                
                latestExtendedWeatherFetched = result
                print("Extended Fetch Successful")
                
                if var fetchedDays = latestExtendedWeatherFetched?.dailyWeather, let fetchedHours = latestExtendedWeatherFetched?.hourlyWeather{
                    
                    var dayIndex = 0
                    var newHourlyArray = [HourData]()
                    
                    for hour in fetchedHours {
                       
                        if hour.dayNumber == fetchedDays[dayIndex].dayNumber{
                        
                            newHourlyArray.append(hour)
                        } else{
                            
                            //fetchedDays[dayIndex].hourData = newHourlyArray
                            latestExtendedWeatherFetched!.dailyWeather![dayIndex].hourData = newHourlyArray
                            newHourlyArray.removeAll()
                            dayIndex += 1
                        }
                    }
                }
             
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                
                print("Extended Fetch Failed")
                self.toggleLoadingMode(true)
                showAlert(viewController: self, title: "Error fetching data", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
                
            default: break
            }
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {

        print("\nWhen starting motionBegan:")
        print(" - willAllowLocationServices: ", UserDefaults.standard.bool(forKey: "willAllowLocationServices"))
        print(" - isFetching: ", isFetching)
        
        // test
        
        if UserDefaults.standard.bool(forKey: "willAllowLocationServices") == true && isFetching == false {
            
            print("willAllowLocationServices is true and isFetching is false, so starting fetch")
            UserLocation.sharedInstance.updateLocation() // Fetches weather after gps update
        } else {
            
            // User has not allowed Location Services
            
            let alertMe = UIAlertController(title: "Location Services needed", message: "In order to provide you with the latest local weather, you need to give us access to your location!", preferredStyle: UIAlertControllerStyle.alert)
            
            alertMe.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.cancel, handler: nil))
            
            alertMe.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                
                UserDefaults.standard.setValue(true, forKey: "willAllowLocationServices")
                UserDefaults.standard.synchronize()
                UserLocation.sharedInstance.updateLocation()
            }))
            
            present(alertMe, animated: true, completion: nil)
        }
    }

    func settingsDidUpdate(){
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        updateExtendedCurrentWeather()
    }

    func reverseGeocodeHandler(){
        
        if let latestGPS = UserLocation.sharedInstance.coordinate{
            
            currentCoordinate = latestGPS
            updateExtendedCurrentWeather()
        
        } else {
            showAlert(viewController: self, title: "Error fetching gps", message: "We can fetch weather for you if you let us access Location Services. Please enable Location Services in your settings and restart the app to update GPS.", error: nil)
        }
    }
}
