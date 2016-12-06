//
//  CurrentWeather.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 05/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation

// Data structures

struct HourData{
    
    let apparentTemperature: Double
    let cloudCover: Double
    let dewPoint: Double
    let humidity: Double
    let weatherIcon: Icon
    let ozone: Double
    let precipIntensity: Double
    let precipProbability: Double
    let precipType: PrecipIcon
    let pressure: Double
    let summary: String
    let temperature: Double
    let time: Int
    let windBearing: Double
    let windSpeed: Double
}

extension HourData{
    
    // Failable Initializer
    init?(hourDictionary: [String : AnyObject]) {
        
        guard let apparentTemperature = hourDictionary["apparentTemperature"] as? Double,
            let cloudCover = hourDictionary["cloudCover"] as? Double,
            let dewPoint = hourDictionary["dewPoint"] as? Double,
            let humidity = hourDictionary["humidity"] as? Double,
            let icon = hourDictionary["icon"] as? String,
            let ozone = hourDictionary["ozone"] as? Double,
            let precipIntensity = hourDictionary["precipIntensity"] as? Double,
            let precipProbability = hourDictionary["precipProbability"] as? Double,
            let pressure = hourDictionary["pressure"] as? Double,
            let summary = hourDictionary["summary"] as? String,
            let temperature = hourDictionary["temperature"] as? Double,
            let time = hourDictionary["time"] as? Int,
            let windBearing = hourDictionary["windBearing"] as? Double,
            let windSpeed = hourDictionary["windSpeed"] as? Double
            
            else {
                
                print("Følgende HourData init feilet:")
                print(hourDictionary)
                return nil }
        
        self.apparentTemperature = apparentTemperature
        self.cloudCover = cloudCover
        self.dewPoint = dewPoint
        self.humidity = humidity
        self.weatherIcon = Icon(rawValue: icon)
        self.ozone = ozone
        self.precipIntensity = precipIntensity
        self.precipProbability = precipProbability
        self.pressure = pressure
        self.summary = summary
        self.temperature = temperature
        self.time = time
        self.windBearing = windBearing
        self.windSpeed = windSpeed
        
        if precipProbability != 0 {
        
            let precipType = hourDictionary["precipType"] as! String
            self.precipType = PrecipIcon(rawValue: precipType)
        
        } else {
            self.precipType = PrecipIcon.unexpectedPrecip
        }
        
        
        
    }
}

struct MinuteData{
    
    let time: Int
    let precipIntensity: Double
    let precipIntensityError: Double
    let precipProbability: Double
    let precipType: String
}

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

struct ExtendedCurrentWeather{
    
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
    var hourlyWeather: [HourData]?
    var minutelyWeather: [MinuteData]?
    
    // Has extensions

}

extension ExtendedCurrentWeather: JSONDecodable{
    
    init?(JSON fullJSON: [String : AnyObject]) {
        //print(fullJSON)
        
        if let currentlyJSON = fullJSON["currently"] as? [String : AnyObject] {
            
            guard let temperature = currentlyJSON["temperature"] as? Double,
                let summary = currentlyJSON["summary"] as? String,
                let windSpeed = currentlyJSON["windSpeed"] as? Double,
                let humidity = currentlyJSON["humidity"] as? Double,
                let precipIntensity = currentlyJSON["precipIntensity"] as? Double,
                let iconString = currentlyJSON["icon"] as? String,
                let precipProbability = currentlyJSON["precipProbability"] as? Double,
                let time = currentlyJSON["time"] as? Double
                
                else { return nil }
            
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
                
                self.precipTypeText = (currentlyJSON["precipType"] as? String)!
                self.precipIcon = .init(rawValue: self.precipTypeText)
                
            } else {
                
                self.precipTypeText = "Precipitation"
                self.precipIcon = .unexpectedPrecip
            }
            print("successfully initiated extendedCurrentweaters usual part. Now on to hourly")
        } else {
            print("ERROR: making currentlyJSON")
            return nil
        }
        
        // TASK: - : Initialze Array of HourData
        
        print("starter i TODO Initializing hours")
    
        if let hourlyJSON = fullJSON["hourly"] as? [String : AnyObject] {
        
            if let data = hourlyJSON["data"] as? [[String : AnyObject]] {
            
                var array: [HourData] = []
                for hour in data{
        
                    print()
                    let myHourData = HourData(hourDictionary: hour)
                    if let myHourData = myHourData{
                        array.append(myHourData)
                    }
                
                }
                print("count is", array.count)
                self.hourlyWeather = array
                
            }
            
        } else {print("errr getting data from hourlyJSON")}
    
    } // End of hour init
    
}// End of extension

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
    var precipProbability: Double?
    var precipTypeText: String?
    var precipIcon: PrecipIcon?
    var windSpeed: Double
    var humidity: Double
}

extension DailyWeather{
    
    var weekNumber: Int{
    
        let date = NSDate(timeIntervalSince1970: self.time) as Date
        let week = NSCalendar.current.component(.weekOfYear, from: date)
        return week
    }
}

extension CurrentWeather{
    var weekNumber: Int{
        
        let date = NSDate(timeIntervalSince1970: self.time) as Date
        let week = NSCalendar.current.component(.weekOfYear, from: date)
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
        
        //print(JSONDay)
        
        guard let apparentTemperatureMin = JSONDay["apparentTemperatureMin"] as? Double,
            let apparentTemperatureMax = JSONDay["apparentTemperatureMax"] as? Double,
            let temperatureMin = JSONDay["temperatureMin"] as? Double,
            let temperatureMax = JSONDay["temperatureMax"] as? Double,
            let summary = JSONDay["summary"] as? String,
            let weatherIconString = JSONDay["icon"] as? String,
            let windSpeed = JSONDay["windSpeed"] as? Double,
            let humidity = JSONDay["humidity"] as? Double,
            let time = JSONDay["time"] as? Double
            
            else {
                print("'DailyWeather' initializer returnered nil")
                return nil
        }
        
        
        
        
        if let precipProbability = JSONDay["precipProbability"] as? Double{
            self.precipProbability = precipProbability
        } else {
            self.precipProbability = nil
        }
        
        if let precipIntensity = JSONDay["precipIntensity"] as? Double{
            self.precipIntensity = precipIntensity
        } else {
            self.precipIntensity = nil
        }
        
        // precip Icon
        
        if let precipType = JSONDay["precipType"] as? String{
            self.precipTypeText = precipType
            self.precipIcon = PrecipIcon.init(rawValue: precipType)
        } else{
            self.precipTypeText = "Precipitation"
            self.precipIcon = PrecipIcon.unexpectedPrecip
        }
        
        self.apparentTemperatureMin = apparentTemperatureMin
        self.apparentTemperatureMax = apparentTemperatureMax
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.summary = summary
        self.weatherIcon = Icon(rawValue: weatherIconString)
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
    
    var precipProbabilityPercentage: Int?{
        
        if let precipProbability = self.precipProbability{
            return Int(precipProbability*100)
        } else {
            return nil
        }
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
