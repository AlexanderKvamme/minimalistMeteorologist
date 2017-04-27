//
//  YrWeatherModel.swift
//  myXMLTest
//
//  Created by Alexander Kvamme on 18/04/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

struct YrHourData: CustomStringConvertible, HasDayNumber {
    var timeTo: Double
    var timeFrom: Double
    var time: Double
    private var temperatureInCelcius: Int // Default unit from Yr
    var temperatureUnit: String
    var temperature: Double {
        // returns temperature dependent if user preference for unit
        let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")!
        switch currentPreferredUnits{
        case "US":
            // convert to fahrenheit
            return Double(temperatureInCelcius) * 9/5 + 32
        default: return Double(temperatureInCelcius)
        }
    }
    
    init(to: Double, from: Double, temperatureUnit: String, temperatureValue: String) {
        self.timeTo = to
        self.timeFrom = from
        self.time = from // used for hasDayNumber calculations
        self.temperatureUnit = temperatureUnit
        if let double = Int(temperatureValue) {
            self.temperatureInCelcius = double
        } else {
            fatalError("YrHourData could not cast to double")
        }
        print("fetched hour \(self)")
    }
    
    var description: String {
        return "\(timeFrom) -- \(timeTo) -- \(temperatureInCelcius) -- \(temperatureUnit)"
    }
}
