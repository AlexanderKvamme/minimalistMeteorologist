//
//  CurrentWeather.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 05/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation

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

enum icon: String{
    
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

enum precipIcon: String{
    
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

struct CurrentWeather{
    
    var timezone: timezone?
    var offset: Int?
    var temperature: Double
    var summary: String
    var WeatherIcon: icon
    var precipIcon: precipIcon
    var time: Double
    
// Average values:
    
    // let precip: Double //Gjennomsnittlig mm med regn
    // let precipType: icon //regn, snø eller sludd
    var precipIntensity: Double?
    var precipProbability: Double
    var precipProbabilityPercentage: Int
    var windSpeed: Double //måles i mph
    var humidity: Double
    var precipTypeText: String
}

extension CurrentWeather: JSONDecodable{
    
    init?(JSON: [String : AnyObject]) {

        guard let temperature = JSON["temperature"] as? Double,
        let summary = JSON["summary"] as? String,
        let windSpeed = JSON["windSpeed"] as? Double,
        let humidity = JSON["humidity"] as? Double,
        let precipIntensity = JSON["precipIntensity"] as? Double,
        let iconString = JSON["icon"] as? String,
        let precipProbability = JSON["precipProbability"] as? Double,
        let time = JSON["time"] as? Double
        
            else {
                return nil
        }
        
        self.temperature = temperature
        self.summary = summary
        self.windSpeed = windSpeed
        self.humidity = humidity
        self.precipIntensity = precipIntensity
        self.WeatherIcon = icon(rawValue: iconString)
    
        self.precipProbability = precipProbability
        self.precipProbabilityPercentage = Int(precipProbability*100)
        
        self.time = time
        
        // Optionals precipitation: If precipitation probability == 0 there will not be a precipation type so default is needed to display en custom default icon
        
        if precipProbability != 0 {
            
            self.precipTypeText = (JSON["precipType"] as? String)!
            self.precipIcon = .init(rawValue: self.precipTypeText)
            
        } else {
            
            self.precipTypeText = "Precipitation"
            self.precipIcon = .unexpectedPrecip
        }
    }
}

// Measurements for displaying unit system specific values and unit

extension CurrentWeather{
    
    var temperatureWithUnit: Measurement<Unit> {
        
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        
        switch preferredUnitSystem{
            
        case "US":
            return Measurement(value: self.temperature, unit: UnitTemperature.fahrenheit)
            
        default:
            return Measurement(value: self.temperature, unit: UnitTemperature.celsius)
        }
    }
    
    var windSpeedWithUnit: Measurement<Unit> {
        
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        
        switch preferredUnitSystem{
        
        case "CA":
            return Measurement(value: self.windSpeed, unit: UnitSpeed.kilometersPerHour)
            
        case "UK2", "US":
            return Measurement(value: self.windSpeed, unit: UnitSpeed.milesPerHour)
            
        default:
            return Measurement(value: self.windSpeed, unit: UnitSpeed.metersPerSecond)
        }
    }
}
