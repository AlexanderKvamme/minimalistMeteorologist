//
//  CurrentWeather.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 05/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation

// Data structures

struct CurrentWeather{
    
    var timezone: timezone?
    var offset: Int?
    var temperature: Double
    var summary: String
    var WeatherIcon: Icon
    var precipIcon: PrecipIcon
    var time: Double
    var precipIntensity: Double?
    var precipProbability: Double
    var precipProbabilityPercentage: Int
    var windSpeed: Double
    var humidity: Double
    var precipTypeText: String
}

struct DailyWeather{
    
    var apparentTemperatureMin: Double
    var apparentTemperatureMax: Double
    var averageTemperature: Double
    var temperatureMin: Double
    var temperatureMax: Double
    var summary: String
    var weatherIcon: Icon
    var time: Double
    var precipIntensity: Double?
    var precipType: String?
    var precipProbability: Double
    var precipTypeText: String?
    var windSpeed: Double
    var humidity: Double    
    
    var precipProbabilityPercentage: Int{
        return Int(precipProbability*100)
    }
    
    var precipIcon: PrecipIcon{
        
        if precipProbability != 0 {
            if let precipTypeText = precipTypeText{
                return .init(rawValue: precipTypeText)
            }
        }
        return .unexpectedPrecip
    }
}

extension DailyWeather{
    
    var weekNumber: Int{
    
        let date = NSDate(timeIntervalSince1970: self.time) as Date
        let week = NSCalendar.current.component(.weekOfYear, from: date)
        print("returning week nr as: ", week)
        return week
    }
    
}

extension CurrentWeather{
    var weekNumber: Int{
        
        let date = NSDate(timeIntervalSince1970: self.time) as Date
        let week = NSCalendar.current.component(.weekOfYear, from: date)
        print("returning week nr as: ", week)
        return week
    }
}

struct WeeklyWeather{
    
    var DailyWeatherArray: [DailyWeather]
    
    init(Days: [DailyWeather]){
        
        self.DailyWeatherArray = Days
    }
}

// Failable Initializers

extension DailyWeather{
    
    init?(JSONDay: [String : AnyObject]){
        
        guard let apparentTemperatureMin = JSONDay["apparentTemperatureMin"] as? Double,
            let apparentTemperatureMax = JSONDay["apparentTemperatureMax"] as? Double,
            let temperatureMin = JSONDay["temperatureMin"] as? Double,
            let temperatureMax = JSONDay["temperatureMax"] as? Double,
            let summary = JSONDay["summary"] as? String,
            let weatherIconString = JSONDay["icon"] as? String,
            let precipProbability = JSONDay["precipProbability"] as? Double,
            let windSpeed = JSONDay["windSpeed"] as? Double,
            let humidity = JSONDay["humidity"] as? Double,
            let time = JSONDay["time"] as? Double
            
            else {
                print("'DailyWeather' initializer returnered nil")
                return nil
        }
        
        if let precipIntensity = JSONDay["precipIntensity"] as? Double{
            
            self.precipIntensity = precipIntensity
        } else {
            self.precipIntensity = nil
        }
        
        self.apparentTemperatureMin = apparentTemperatureMin
        self.apparentTemperatureMax = apparentTemperatureMax
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.summary = summary
        self.weatherIcon = Icon(rawValue: weatherIconString)
        
        self.precipProbability = precipProbability
        self.windSpeed = windSpeed
        self.humidity = humidity
        self.time = time
        self.averageTemperature = (temperatureMax+temperatureMin)/2
    }
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
        self.WeatherIcon = Icon(rawValue: iconString)
        self.precipProbability = precipProbability
        self.precipProbabilityPercentage = Int(precipProbability*100)
        self.time = time
        
        if precipProbability != 0 {
            
            self.precipTypeText = (JSON["precipType"] as? String)!
            self.precipIcon = .init(rawValue: self.precipTypeText)
            
        } else {
            
            self.precipTypeText = "Precipitation"
            self.precipIcon = .unexpectedPrecip
        }
    }
}

// Date

extension DailyWeather{
    var date: Date {
        return Date.init(timeIntervalSince1970: self.time)
    }
}

// Measurements for displaying unit system specific values and unit

extension DailyWeather{
    
    var averageTemperatureInPreferredUnit: Measurement<Unit> {
        
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        
        switch preferredUnitSystem{
            
        case "US":
            return Measurement(value: round(self.averageTemperature), unit: UnitTemperature.fahrenheit)
            
        default:
            return Measurement(value: round(self.averageTemperature), unit: UnitTemperature.celsius)
        }
    }
    
    var windSpeedInPreferredUnit: Measurement<Unit> {
        
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        
        switch preferredUnitSystem{
            
        case "CA":
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.kilometersPerHour)
            
        case "UK2", "US":
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.milesPerHour)
            
        default:
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.metersPerSecond)
        }
    }
}

extension CurrentWeather{
    
    var temperatureInPreferredUnit: Measurement<Unit> {
        
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        
        switch preferredUnitSystem{
            
        case "US":
            return Measurement(value: self.temperature, unit: UnitTemperature.fahrenheit)
            
        default:
            return Measurement(value: self.temperature, unit: UnitTemperature.celsius)
        }
    }
    
    var windSpeedInPreferredUnit: Measurement<Unit> {
        
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
