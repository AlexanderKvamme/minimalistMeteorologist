//
//  WeatherRefactored.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 31/01/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: - Data structures

struct HourData: HasDayNumber{
    let apparentTemperature: Double
    let cloudCover: Double
    let weatherIcon: Icon
    let precipIntensity: Double
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
    let WeatherIcon: Icon
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

struct DayData: HasDayName, windSpeedInPreferredUnit, HasDayNumber, HasAverageTemperature{
    let summary: String
    let weatherIcon: Icon
    let time: Double
    let precipIntensity: Double?
    let precipProbability: Double
    let precipIcon: PrecipitationIcon
    var windSpeed: Double
    var hourData: [HourData]?
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
        self.weatherIcon = Icon(rawValue: icon)
        self.summary = summary
        self.temperature = temperature
        self.time = time
        self.windSpeed = windSpeed
        self.precipIntensity = precipIntensity
        self.precipProbability = precipProbability
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
        let precipType = JSONDay["precipType"] as? String,
        let precipProbability = JSONDay["precipProbability"] as? Double
            else {
                return nil
        }
        self.summary = summary
        self.weatherIcon = Icon(rawValue: weatherIconString)
        self.windSpeed = windSpeed
        self.time = time
        self.precipProbability = precipProbability
        self.precipIcon = precipProbability != 0 ? .init(rawValue: precipType) : .undefined
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
        self.WeatherIcon = Icon(rawValue: iconString)
        self.precipProbability = precipProbability
        self.time = time
        self.precipIcon = precipProbability != 0 ? .init(rawValue: precipType) : .undefined
    }
}

extension DayData{
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: self.time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    var date: Date {
        return Date.init(timeIntervalSince1970: self.time)
    }
}

// MARK: - Protocol Extensions

// MARK: HasDayName

protocol HasDayName{
    var dayName: String { get }
    var time: Double { get }
}

extension HasDayName{
    var dayName: String{
        let date = Date(timeIntervalSince1970: self.time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: date)
        return dayOfWeekString
    }
}

// MARK: HasDayNumber

protocol HasDayNumber{
    var dayNumber: Int { get }
    var time: Double { get }
}

extension HasDayNumber{
    var dayNumber: Int{
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: self.time)
        let components = calendar.dateComponents([.day,.month,.year], from: date)
        return components.day!
    }
}

// MARK: HasAverageTemperature

protocol HasAverageTemperature {
    var hourData: [HourData]? { get set}
}

extension HasAverageTemperature{
    var averageTemperature: Double{
        var sum: Double = 0
        if let hourData = hourData{
            for hour in hourData{
                sum += hour.temperature
            }
        }
        return sum/Double(hourData!.count)
    }
}

// MARK: - Helper functions

func dailyArrayFromJSON(_ dailyData: [[String : AnyObject]]) -> [DayData]{
    var arrayOfDayData: [DayData] = []
    for day in dailyData{
        let myDayData = DayData(JSONDay: day)
        if let myDayData = myDayData{
            arrayOfDayData.append(myDayData)
        }
    }
    return arrayOfDayData
}

func hourlyArrayFromJSON(_ hourlyData: [[String : AnyObject]]) -> [HourData]{
    var arrayOfHourData: [HourData] = []
    for hour in hourlyData{
        let myHourData = HourData(hourDictionary: hour)
        if let myHourData = myHourData{
            arrayOfHourData.append(myHourData)
        }
    }
    return arrayOfHourData
}
