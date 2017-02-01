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
    let dewPoint: Double
    let humidity: Double
    let weatherIcon: Icon
    let ozone: Double
    let precipIntensity: Double
    let precipProbability: Double
    let precipType: PrecipitationIcon
    let pressure: Double
    let summary: String
    let temperature: Double
    let time: Double
    let windBearing: Double
    let windSpeed: Double
}

struct MinuteData{
    let time: Double
    let precipIntensity: Double
    let precipIntensityError: Double
    let precipProbability: Double
    let precipType: String
}

struct CurrentData: HasDayName{
    let temperature: Double
    let summary: String
    let WeatherIcon: Icon
    let precipIcon: PrecipitationIcon
    let time: Double
    let precipIntensity: Double?
    let precipProbability: Double
    let windSpeed: Double
    let humidity: Double
    let precipType: String
}

struct ExtendedCurrentData{
    var currentWeather: CurrentData?
    var dailyWeather: [DayData]?
    var hourlyWeather: [HourData]?
    var minutelyWeather: [MinuteData]?
}

struct DayData: HasDayName, windSpeedInPreferredUnit, HasDayNumber{
    let summary: String
    let weatherIcon: Icon
    let time: Double
    let precipIntensity: Double?
    let precipProbability: Double?
    let precipType: String?
    let precipIcon: PrecipitationIcon?
    var windSpeed: Double
    let humidity: Double?
    var hourData: [HourData]?
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

// MARK: Failable initializers

extension HourData{
    
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
            let time = hourDictionary["time"] as? Double,
            let windBearing = hourDictionary["windBearing"] as? Double,
            let windSpeed = hourDictionary["windSpeed"] as? Double
            else {
                return nil
        }
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
            self.precipType = PrecipitationIcon(rawValue: hourDictionary["precipType"] as! String)
        } else {
            self.precipType = PrecipitationIcon.undefined
        }
    }
}

extension ExtendedCurrentData: JSONDecodable{
    
    init?(JSON fullJSON: [String : AnyObject]) {
        if let currentlyJSON = fullJSON["currently"] as? [String : AnyObject] {
            if let currentWeather = CurrentData(JSON: currentlyJSON){
                self.currentWeather = currentWeather
            } else {
                self.currentWeather = nil
            }
        }
        if let dailyJSON = fullJSON["daily"] as? [String : AnyObject]{
            if let data = dailyJSON["data"] as? [[String : AnyObject]] {
                var array: [DayData] = []
                for day in data{
                    let myDayData = DayData(JSONDay: day)
                    if let myDayData = myDayData{
                        array.append(myDayData)
                    }
                }
                self.dailyWeather = array
            }
        }
        
        if let hourlyJSON = fullJSON["hourly"] as? [String : AnyObject] {
            if let data = hourlyJSON["data"] as? [[String : AnyObject]] {
                var array: [HourData] = []
                for hour in data{
                    let myHourData = HourData(hourDictionary: hour)
                    if let myHourData = myHourData{
                        array.append(myHourData)
                    }
                }
                self.hourlyWeather = array
            }
        } else {
            print("Error getting data from hourlyJSON")
        }
    }
}

extension DayData{
    
    init?(JSONDay: [String : AnyObject]){
        guard let summary = JSONDay["summary"] as? String,
            let weatherIconString = JSONDay["icon"] as? String,
            let windSpeed = JSONDay["windSpeed"] as? Double,
            let time = JSONDay["time"] as? Double
            else {
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
        if let precipType = JSONDay["precipType"] as? String{
            self.precipType = precipType
            self.precipIcon = PrecipitationIcon.init(rawValue: precipType)
        } else {
            self.precipType = "Precipitation"
            self.precipIcon = PrecipitationIcon.undefined
        }
        self.summary = summary
        self.weatherIcon = Icon(rawValue: weatherIconString)
        self.windSpeed = windSpeed
        self.humidity = nil
        self.time = time
    }
}

extension CurrentData: JSONDecodable{
    
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
        self.time = time
        if precipProbability != 0 {
            self.precipType = (JSON["precipType"] as? String)!
            self.precipIcon = .init(rawValue: self.precipType)
        } else {
            self.precipType = "Precipitation"
            self.precipIcon = .undefined
        }
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

