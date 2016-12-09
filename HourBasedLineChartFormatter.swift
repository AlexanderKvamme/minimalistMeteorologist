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
        let newString = String(newInt)
        
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
        
        print()
        print("HH: ", HH)
        print("MM: ", MM)
        
        let returnString = HH + ":" + MM
        
        return returnString
    }
}
