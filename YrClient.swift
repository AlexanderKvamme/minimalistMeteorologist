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
    
    // FIXME: - Async fetch med completion handler
    
    func fetchHourlyWeather(completion: @escaping (XMLResult) -> Void){
        
        //        // Når vi kaller på denne må vi sende med en completionHandler funksjon { APIResult<[YrHourData]>
        //        fetch(request: request, parse: { json -> ExtendedCurrentData? in
        //            return ExtendedCurrentData(JSON: json)
        //        }, completion: completion)
    }
    
    // fetchmetoden
    func fetch(completion: @escaping (APIResult<[YrHourData]>) -> Void ){
        
        DispatchQueue.main.async {
            //YrXMLParser.beginParsing()
        }
        
        //            DispatchQueue.main.async(execute: { () -> Void in
        //
        //                guard let json = json else {
        //                    if let error = error {
        //                        completion(APIResult.failure(error))
        //                    }
        //                    return
        //                }
        //                if let value = parse(json) {
        //                    completion(APIResult.success(value))
        //                } else {
        //                    let error = NSError(domain: AMKNetworkingErrorDomain, code: JSONParsingError, userInfo: nil)
        //                    completion(APIResult.failure(error))
        //                }
        //            })
        //        task.resume()
    }
}

enum XMLResult {
    case Success(result: [YrHourData])
    case Failure(error: String)
}
