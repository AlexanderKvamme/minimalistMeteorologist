//
//  Global.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 31/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

/*
 
 Table of content:
 -----------------
 
 Globals:
 - Variables
 
 Enums:
 - unitSystem
 - unitsOfMeasurement
 
 Functions:
 - showAlert()
 - setUserDefaultsIfInitialRun()
 - getCurrentWeekNumber()

*/

// MARK: - Globals

var currentCoordinate = Coordinate(lat: 59.911491, lon: 10.757933) // Default value lets user test app without having to enable location services

// MARK: - Enums

enum Icon: String{
    
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain = "rain"
    case snow = "snow"
    case sleet = "sleet"
    case precipitation = "precip"
    case wind = "wind"
    case fog = "fog"
    case cloudy = "cloudy"
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"
    case unexpectedEnum = "default"
    
    init(rawValue: String){
        
        switch rawValue{
        case "clear-day": self = .clearDay
        case "clear-night": self = .clearNight
        case "rain": self = .rain
        case "snow": self = .snow
        case "precipitaion": self = .precipitation
        case "sleet" : self = .sleet
        case "wind" : self = .wind
        case "fog" : self = .fog
        case "cloudy": self = .cloudy
        case "partly-cloudy-day": self = .partlyCloudyDay
        case "partly-cloudy-night": self = .partlyCloudyNight
            
        default:
            self = .unexpectedEnum
        }
    }
}

enum PrecipIcon: String{
    
    case sleet = "precipitationSleet"
    case rain = "precipitationRain"
    case snow = "precipitationSnow"
    case unexpectedPrecip = "precipitationDefault"
    
    init(rawValue: String){
        
        switch rawValue{
        case "sleet": self = .sleet
        case "rain": self = .rain
        case "snow" : self = .snow
        default: self = .unexpectedPrecip
        }
    }
}


enum unitSystem: String {
    case CA = "CA"
    case UK2 = "UK2"
    case US = "US"
    case SI = "SI"
    case unexpectedUnit = "unexpectedUnit"
    
    init(rawValue: String){
        
        switch rawValue{
            
        case "CA":
            self = .CA
            unitsOfMeasurement.sharedInstance.windSpeedUnit = "km/h"
            unitsOfMeasurement.sharedInstance.nearestStormDistance = "km"
            unitsOfMeasurement.sharedInstance.temperature = "°C"
            unitsOfMeasurement.sharedInstance.visibility = "km"
            
        case "UK2":
            self = .UK2
            unitsOfMeasurement.sharedInstance.windSpeedUnit = "MPH"
            unitsOfMeasurement.sharedInstance.nearestStormDistance = "miles"
            unitsOfMeasurement.sharedInstance.temperature = "°C"
            unitsOfMeasurement.sharedInstance.visibility = "miles"
            
        case "US":
            self = .US
            unitsOfMeasurement.sharedInstance.windSpeedUnit = "ft/s"
            unitsOfMeasurement.sharedInstance.nearestStormDistance = "km"
            unitsOfMeasurement.sharedInstance.temperature = "°F"
            unitsOfMeasurement.sharedInstance.visibility = "km"
            
        case "SI":
            self = .SI
            unitsOfMeasurement.sharedInstance.windSpeedUnit = "m/s"
            unitsOfMeasurement.sharedInstance.nearestStormDistance = "km"
            unitsOfMeasurement.sharedInstance.temperature = "°C"
            unitsOfMeasurement.sharedInstance.visibility = "km"
            
        default: self = .unexpectedUnit
        }
    }
}

struct unitsOfMeasurement {
    
    static var sharedInstance = unitsOfMeasurement()
    
    var windSpeedUnit: String = "km"
    var nearestStormDistance: String = "km"
    var temperature: String = "°C"
    var visibility: String = "km"
    
    private init(){}
}

struct unitsOfMeasurement2{
    
    var windSpeedUnit: String
    var nearestStormDistance: String
    var temperature: String
    var visibility: String
    
    init(windSpeedUnit: String, nearestStormDistance: String, temperature: String, visibility: String){
        self.windSpeedUnit = windSpeedUnit
        self.nearestStormDistance = nearestStormDistance
        self.temperature = temperature
        self.visibility = visibility
    }
}


func showAlert(viewController: UIViewController, title: String, message: String, error: NSError?){
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(dismissAction)
    
    viewController.present(alertController, animated: true, completion: nil)
}

// Setting standard userPref if first time run

func setUserDefaultsIfInitialRun(){
    
    let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")
    
    if currentPreferredUnits == nil {
        UserDefaults.standard.set("SI", forKey: "preferredUnits")
    }
}

func getCurrentWeekNumber() -> Int {
    
    let currentDate = NSDate()
    let week = NSCalendar.current.component(.weekOfYear, from: currentDate as Date)
    return Int(week)
}
