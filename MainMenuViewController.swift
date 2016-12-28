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
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUserDefaultsIfInitialRun()
        
        // Set observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.reverseGeocodeHandler), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        updateExtendedCurrentWeatherTest()
        
        UserLocation.sharedInstance.updateLocation()
        
        //animation test
        
        activityIndicator.startAnimating()
    
        self.buttonStack.isUserInteractionEnabled = false
        self.buttonStack.alpha = 0.7
    
    }

    func updateExtendedCurrentWeatherTest(){
        
        forecastClient.fetchExtendedCurrentWeather(currentCoordinate) { apiresult in
            
            //self.activityIndicator.startAnimating()
            
            switch apiresult{
                
            case .success(let result):
                
                latestExtendedWeatherFetched = result
                print("Extended Fetch Successful")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.checkmarkView.isHidden = false
                Animations.playCheckmarkAnimationOnce(inImageView: self.checkmarkView)
             
                self.buttonStack.isUserInteractionEnabled = true
                self.buttonStack.alpha = 1
                
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

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                //print("result: ", extendedWeather)
                
                //self.activityIndicator.stopAnimating()
                
                // TASK: TODO - EXTENDED HOURS TO DAYS
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
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
        Animations.playCheckmarkAnimationOnce(inImageView: checkmarkView)
    }

    func reverseGeocodeHandler(){
        
        if let latestGPS = UserLocation.sharedInstance.coordinate{
            
            currentCoordinate = latestGPS
        
        } else {
            showAlert(viewController: self, title: "Error fetching gps", message: "We can fetch weather for you if you let us access Location Services. Please enable Location Services in your settings and restart the app to update GPS.", error: nil)
        }
    }
}

func timestampsAreOnSameDay(stamp: Double, and stamp2: Double) -> Bool{
    
    let calendar = Calendar.current
    
    let date1 = Date(timeIntervalSince1970: stamp)
    let date2 = Date(timeIntervalSince1970: stamp2)
    
    let components1 = calendar.dateComponents([.day,.month,.year], from: date1)
    let components2 = calendar.dateComponents([.day,.month,.year], from: date2)
    
    //print("day1:", components1.day ?? "no day")
    //print("day2:", components2.day ?? "no day 2")

    if components1.day! == components2.day! {
        return true
    } else
    {return false}
    
}
