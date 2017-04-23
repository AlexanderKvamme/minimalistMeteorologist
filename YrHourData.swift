//
//  YrWeatherModel.swift
//  myXMLTest
//
//  Created by Alexander Kvamme on 18/04/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation

struct YrHourData: CustomStringConvertible {
    
    var timeStringTo: Double
    var timeStringFrom: Double
    var temperatureValue: Int
    var temperatureUnit: String
    
    init(to: Double, from: Double, temperatureUnit: String, temperatureValue: String) {
        self.timeStringTo = to
        self.timeStringFrom = from
        self.temperatureUnit = temperatureUnit
        if let double = Int(temperatureValue) {
            self.temperatureValue = double
        } else {
            fatalError("YrHourData could not cast to double")
        }
    }
    
    var description: String {
        return "\(timeStringFrom) -- \(timeStringTo) -- \(temperatureValue) -- \(temperatureUnit)"
    }
}
