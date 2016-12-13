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
                
            case .success(let result):
                
                latestExtendedWeatherFetched = result
                
                // TASK: TODO - ARRANGE HOURS TO CORRECT DAYS
                
                
                if let dagensStamp = latestExtendedWeatherFetched?.currentWeather?.time {
                
                print("samme dag: ", timestampsAreOnSameDay(stamp: 1481574616.0, and: dagensStamp))
                }
                
                
                
                // Arrange hours from fetch in corresponding DailyWeather.hourData
                
                if var fetchedDays = latestExtendedWeatherFetched?.dailyWeather, let fetchedHours = latestExtendedWeatherFetched?.hourlyWeather{
                    
                    var dayIndex = 0
                    var newHourlyArray = [HourData]()
                    
                    for hour in fetchedHours {
                       
                        if hour.dayNumber == fetchedDays[dayIndex].dayNumber{
                        
                            newHourlyArray.append(hour)
                        } else{
                            
                            fetchedDays[dayIndex].hourData = newHourlyArray
                            newHourlyArray.removeAll()
                            dayIndex += 1
                        }
                    }
                    
                    for (index, day) in fetchedDays.enumerated(){
                        print("hours in day \(day.dayNumber)", fetchedDays[index].hourData?.count)
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
