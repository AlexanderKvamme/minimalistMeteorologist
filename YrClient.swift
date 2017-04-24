//
//  myViewController.swift
//  myXMLTest
//
//  Created by Alexander Kvamme on 18/04/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import Foundation

class YrClient: NSObject, XMLParserDelegate {
    
    var currentXMLContent = String()
    var hourDataArray = [YrHourData]()
    
    var parsedOffset = 0
    var parsedTimeTo = ""
    var parsedTimeFrom = ""
    var parsedTemperatureValue = ""
    var parsedTemperatureUnit = ""
    var inTabular = false
    
    // Temporary enkel fetch
    
    func fetchHourlyDataFromYr(URL urlString: String, completion: @escaping ((XMLResult) -> Void)) {
        DispatchQueue.main.async{
            let parser = YrXMLParser()
            parser.getHourlyData(fromURL: urlString, completion: { (result) in
                completion(result)
            })
        }
    }
}

enum XMLResult {
    case Success(result: [YrHourData])
    case Failure(error: String)
}
