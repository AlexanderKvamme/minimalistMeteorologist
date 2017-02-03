//
//  HourBasedLineChartFormatter.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/12/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation
import Charts

class TimeStampFormatter: NSObject, IAxisValueFormatter{
    
    // Used by Charts to get HH:MM format along the x-axis
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var stringForm = String(Int(value))
        if stringForm.length == 3{
            stringForm = "0" + stringForm
        }
        // if time input is 0, add zeroes manually: 00:00
        if stringForm.length == 1{
            stringForm = "0000"
        }
        let charForm  = stringForm.characters
        var HH: String = ""
        var MM: String = ""
        var i = 0
        
        // FIXME: - Maybe do this manually, its more readable
        for character in charForm{
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

