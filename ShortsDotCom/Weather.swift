

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
    case undefined = "precipitationDefault"
    
    init(rawValue: String){
        switch rawValue{
        case "sleet": self = .sleet
        case "rain": self = .rain
        case "snow" : self = .snow
        default: self = .undefined
        }
    }
}



// MARK: - Extensions

// MARK: - averageTemperatureInPreferredUnit

extension DayData{
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

extension CurrentData{
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



