//
//  CurrentWeather.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 05/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation

// MARK: - Enum

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

enum PrecipitationIcon: String{
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

// MARK: - Data structures

struct DayData{
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
    var precipIcon: PrecipitationIcon?
    var windSpeed: Double
    var humidity: Double
}

struct HourData{
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
    var dayNumber: Int{
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: self.time)
        let components = calendar.dateComponents([.day,.month,.year], from: date)
        return components.day!
    }
}

struct MinuteData{
    let time: Double
    let precipIntensity: Double
    let precipIntensityError: Double
    let precipProbability: Double
    let precipType: String
}

struct CurrentWeather: DayNameable{
    var timezone: timezone?
    var offset: Int?
    var temperature: Double
    var summary: String
    var WeatherIcon: Icon
    var precipIcon: PrecipitationIcon
    var time: Double
    var precipIntensity: Double?
    var precipProbability: Double
    var precipProbabilityPercentage: Int
    var windSpeed: Double
    var humidity: Double
    var precipTypeText: String
}

struct ExtendedCurrentWeather{
    var currentWeather: CurrentWeather?
    var dailyWeather: [DailyWeather]?
    var hourlyWeather: [HourData]?
    var minutelyWeather: [MinuteData]?
}

struct DailyWeather: DayNameable, windSpeedInPreferredUnit{
    // FIXME: - Use DayData
    var apparentTemperatureMin: Double
    var apparentTemperatureMax: Double
    var temperatureMin: Double
    var temperatureMax: Double
    var summary: String
    var weatherIcon: Icon
    var time: Double
    var precipIntensity: Double?
    var precipProbability: Double?
    var precipTypeText: String?
    var precipIcon: PrecipitationIcon?
    var windSpeed: Double
    var humidity: Double?
    var dayNumber: Int{
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: self.time)
        let components = calendar.dateComponents([.day,.month,.year], from: date)
        return components.day!
    }
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

struct WeeklyWeather{
    var DailyWeatherArray: [DailyWeather]
    
    init(Days: [DailyWeather]){
        self.DailyWeatherArray = Days
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
            self.precipType = PrecipitationIcon.unexpectedPrecip
        }
    }
}

extension ExtendedCurrentWeather: JSONDecodable{
    
    init?(JSON fullJSON: [String : AnyObject]) {
        if let currentlyJSON = fullJSON["currently"] as? [String : AnyObject] {
            if let currentWeather = CurrentWeather(JSON: currentlyJSON){
                self.currentWeather = currentWeather
            } else {
                self.currentWeather = nil
            }
        }
        if let dailyJSON = fullJSON["daily"] as? [String : AnyObject]{
            if let data = dailyJSON["data"] as? [[String : AnyObject]] {
                var array: [DailyWeather] = []
                for day in data{
                    let myDayData = DailyWeather(JSONDay: day)
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

extension DailyWeather{
    
    init?(JSONDay: [String : AnyObject]){
        guard let apparentTemperatureMin = JSONDay["apparentTemperatureMin"] as? Double,
            let apparentTemperatureMax = JSONDay["apparentTemperatureMax"] as? Double,
            let temperatureMin = JSONDay["temperatureMin"] as? Double,
            let temperatureMax = JSONDay["temperatureMax"] as? Double,
            let summary = JSONDay["summary"] as? String,
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
            self.precipTypeText = precipType
            self.precipIcon = PrecipitationIcon.init(rawValue: precipType)
        } else {
            self.precipTypeText = "Precipitation"
            self.precipIcon = PrecipitationIcon.unexpectedPrecip
        }
        self.apparentTemperatureMin = apparentTemperatureMin
        self.apparentTemperatureMax = apparentTemperatureMax
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.summary = summary
        self.weatherIcon = Icon(rawValue: weatherIconString)
        self.windSpeed = windSpeed
        self.humidity = nil
        self.time = time
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

extension DailyWeather{
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: self.time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
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

// MARK: - Extensions

// MARK: - averageTemperatureInPreferredUnit

extension DailyWeather{
    var averageTemperatureInPreferredUnit: Measurement<Unit> {
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        switch preferredUnitSystem{
        case "US":
            if round(self.averageTemperature) == -0 {
                return Measurement(value: 0, unit: UnitTemperature.fahrenheit)
            }
            return Measurement(value: round(self.averageTemperature), unit: UnitTemperature.fahrenheit)
        default:
            if round(self.averageTemperature) == -0 {
                return Measurement(value: 0, unit: UnitTemperature.celsius)
            }
            return Measurement(value: round(self.averageTemperature), unit: UnitTemperature.celsius)
        }
    }
}

// MARK: windSpeedInPreferredUnit

extension CurrentWeather{
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

// MARK: - Extensions with default implementations

// MARK: - Wind speed in preferred units

protocol windSpeedInPreferredUnit{
    var windSpeed: Double { get set }
    var windSpeedInPreferredUnit: Measurement<Unit> { get }
}

extension windSpeedInPreferredUnit{
    var windSpeedInPreferredUnit: Measurement<Unit> {
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        switch preferredUnitSystem{
        case "CA":
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.kilometersPerHour)
        case "UK2", "US":
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.milesPerHour)
        default: return Measurement(value: round(self.windSpeed), unit: UnitSpeed.metersPerSecond)
        }
    }
}

// MARK: DayName

protocol DayNameable{
    var dayName: String { get }
    var time: Double { get set }
}

extension DayNameable{
    var dayName: String{
        let date = Date(timeIntervalSince1970: self.time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: date)
        return dayOfWeekString
    }
}

