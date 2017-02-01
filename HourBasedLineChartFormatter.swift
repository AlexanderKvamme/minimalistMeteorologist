//
//  HourBasedLineChartFormatter.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/12/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation
import Charts

class HourBasedLineChartFormatter: NSObject, IAxisValueFormatter{
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let newInt = Int(value)
        var newString = String(newInt)
        if newString.length == 3{
            newString = "0" + newString
        }
        if newString.length == 1{
            newString = "0000"
        }
        let newCharacters  = newString.characters
        var HH: String = ""
        var MM: String = ""
        var i = 0
        for character in newCharacters{
            if i < 2{
                HH.append(character)
            }else{
                MM.append(character)
            }
            i += 1
        }
        return HH + ":" + MM
    }
}

