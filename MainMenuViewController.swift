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
    
    //MARK: - Properties
    
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkmarkView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var shakeToRefreshImage: UIImageView!
    @IBOutlet weak var enableGPSImage: UIImageView!
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {}
    
    var isFetching = false
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUserDefaultsIfInitialRun()
        
        buttonStack.isUserInteractionEnabled = false
        shakeToRefreshImage.isHidden = true
        activityIndicator.isHidden = true
        
        todayButton.layer.borderWidth = 2
        todayButton.layer.borderColor = UIColor.black.cgColor
        
        if UserDefaults.standard.bool(forKey: "willAllowLocationServices") == true{
            UserLocation.sharedInstance.updateLocation()
        } else {
            toggleLoadingMode(true)
            isFetching = false
            activityIndicator.isHidden = true
            shakeToRefreshImage.isHidden = false
        }
    }
    
    // MARK: - viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        
        // MARK: Set observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(reverseGeocodeHandler), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationManagerFailedHandler), name: NSNotification.Name(rawValue: Notifications.locationManagerFailed), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDidFinishHandler), name: NSNotification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notifications.fetchCurrentWeatherDidFail), object: nil, queue: nil) {
            notification in
            
            if self.presentedViewController == nil {
                showAlert(viewController: self, title: "Server denied fetch", message: "Please try again later", error: nil)
            }
        }
    }
    
    // MARK: viewDidDisappear
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.rootViewController = self
        // Stops unwind from "TODAY" from unwinding further back (Onboarding)
    }

    // FIXME: DU ER HER
    // MARK: -
    
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
        
        case false:
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
    
    func updateExtendedCurrentWeather(){
        
        toggleLoadingMode(true)
        
        forecastClient.fetchExtendedCurrentWeather(currentCoordinate) { apiresult in
            
            self.toggleLoadingMode(false)
            
            switch apiresult{
                
            case .success(let result):
                
                latestExtendedWeatherFetched = result
                
                if var fetchedDays = latestExtendedWeatherFetched?.dailyWeather, let fetchedHours = latestExtendedWeatherFetched?.hourlyWeather{
                    
                    var dayIndex = 0
                    var newHourlyArray = [HourData]()
                    
                    for hour in fetchedHours {
                       
                        if hour.dayNumber == fetchedDays[dayIndex].dayNumber{
                        
                            newHourlyArray.append(hour)
                        } else{
                        
                            latestExtendedWeatherFetched!.dailyWeather![dayIndex].hourData = newHourlyArray
                            newHourlyArray.removeAll()
                            dayIndex += 1
                        }
                    }
                }
        
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                
                self.toggleLoadingMode(true)
                showAlert(viewController: self, title: "Error fetching data", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
                
            default: break
            }
        }
    }
    
    // MARK: - motionBegan
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if UserDefaults.standard.bool(forKey: "willAllowLocationServices") == true && isFetching == false {
            
            print("willAllowLocationServices is true and isFetching is false, so starting fetch")
            UserLocation.sharedInstance.updateLocation() // Fetches weather after gps update
        } else {
            
            // If user has not allowed Location Services
            
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
    
    // MARK: - Observer Handlers
    
    func fetchDidFinishHandler(){
        
        self.shakeToRefreshImage.isHidden = true
        self.enableGPSImage.isHidden = true
    }

    func locationManagerFailedHandler(){
        self.enableGPSImage.isHidden = false
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
