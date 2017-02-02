//
//  WeatherRefactored.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 31/01/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: - Data structures

struct DayData: HasDayName, HasDayNumber, hasWindSpeedInPreferredUnit, hasAverageTemperatureInPreferredUnits{
    let summary: String
    let weatherIcon: WeatherIcon
    let time: Double
    let precipIntensity: Double?
    let precipProbability: Double
    let precipIcon: PrecipitationIcon
    var windSpeed: Double
    var hourData: [HourData]?
}

struct HourData: HasDayNumber{
    let apparentTemperature: Double
    let cloudCover: Double
    let weatherIcon: WeatherIcon
    let precipIntensity: Double?
    let precipProbability: Double
    let precipType: PrecipitationIcon
    let summary: String
    let temperature: Double
    let time: Double
    let windSpeed: Double
}

struct CurrentData: HasDayName{
    let temperature: Double
    let summary: String
    let weatherIcon: WeatherIcon
    let time: Double
    let precipIntensity: Double?
    let precipProbability: Double
    let precipIcon: PrecipitationIcon
    let windSpeed: Double
}

struct ExtendedCurrentData{
    var currentWeather: CurrentData?
    var dailyWeather: [DayData]?
    var hourlyWeather: [HourData]?
}

// MARK: Failable initializers

extension HourData{
    
    init?(hourDictionary: [String : AnyObject]) {
        guard let apparentTemperature = hourDictionary["apparentTemperature"] as? Double,
            let cloudCover = hourDictionary["cloudCover"] as? Double,
            let icon = hourDictionary["icon"] as? String,
            let precipIntensity = hourDictionary["precipIntensity"] as? Double,
            let precipProbability = hourDictionary["precipProbability"] as? Double,
            let summary = hourDictionary["summary"] as? String,
            let temperature = hourDictionary["temperature"] as? Double,
            let time = hourDictionary["time"] as? Double,
            let windSpeed = hourDictionary["windSpeed"] as? Double
            else {
                return nil
        }
        self.apparentTemperature = apparentTemperature
        self.cloudCover = cloudCover
        self.weatherIcon = WeatherIcon(rawValue: icon)
        self.summary = summary
        self.temperature = temperature
        self.time = time
        self.windSpeed = windSpeed
        self.precipProbability = precipProbability
        self.precipIntensity = precipProbability != 0 ? precipIntensity : nil
        self.precipType = precipProbability != 0 ? .init(rawValue: hourDictionary["precipType"] as! String) : .undefined
    }
}

extension ExtendedCurrentData: JSONDecodable{
    
    init?(JSON fullJSON: [String : AnyObject]) {
        guard let currentlyJSON = fullJSON["currently"] as? [String : AnyObject],
            let dailyJSON = fullJSON["daily"] as? [String : AnyObject],
            let dailyData = dailyJSON["data"] as? [[String : AnyObject]],
            let hourlyJSON = fullJSON["hourly"] as? [String : AnyObject],
            let hourlyData = hourlyJSON["data"] as? [[String : AnyObject]]
            else {
                return nil
        }
        
        self.currentWeather = CurrentData(JSON: currentlyJSON)
        self.dailyWeather = dailyArrayFromJSON(dailyData)
        self.hourlyWeather = hourlyArrayFromJSON(hourlyData)
    }
}

extension DayData{
    
    init?(JSONDay: [String : AnyObject]){
        guard let summary = JSONDay["summary"] as? String,
        let weatherIconString = JSONDay["icon"] as? String,
        let windSpeed = JSONDay["windSpeed"] as? Double,
        let time = JSONDay["time"] as? Double,
        let precipProbability = JSONDay["precipProbability"] as? Double
            else {
                return nil
        }
        self.summary = summary
        self.weatherIcon = WeatherIcon(rawValue: weatherIconString)
        self.windSpeed = windSpeed
        self.time = time
        self.precipProbability = precipProbability
        self.precipIcon = precipProbability != 0 ? .init(rawValue: JSONDay["precipType"] as! String) : .undefined
        
        self.precipIntensity = precipProbability != 0 ? JSONDay["precipIntensity"] as? Double : nil
    }
}

extension CurrentData: JSONDecodable{
    
    init?(JSON: [String : AnyObject]) {
        guard let temperature = JSON["temperature"] as? Double,
            let summary = JSON["summary"] as? String,
            let windSpeed = JSON["windSpeed"] as? Double,
            let precipIntensity = JSON["precipIntensity"] as? Double,
            let iconString = JSON["icon"] as? String,
            let precipProbability = JSON["precipProbability"] as? Double,
            let precipType = JSON["precipType"] as? String,
            let time = JSON["time"] as? Double
            else {
                return nil
        }
        self.temperature = temperature
        self.summary = summary
        self.windSpeed = windSpeed
        self.precipIntensity = precipIntensity
        self.weatherIcon = WeatherIcon(rawValue: iconString)
        self.precipProbability = precipProbability
        self.time = time
        self.precipIcon = precipProbability != 0 ? .init(rawValue: precipType) : .undefined
    }
}
