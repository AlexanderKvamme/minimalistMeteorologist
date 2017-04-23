//
//  myViewController.swift
//  myXMLTest
//
//  Created by Alexander Kvamme on 18/04/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import Foundation

class YrXMLParser: NSObject, XMLParserDelegate {
    
    var currentXMLContent = String()
    var hourDataArray = [YrHourData]()
    
    var parsedOffset = 0
    var parsedTimeTo = ""
    var parsedTimeFrom = ""
    var parsedTemperatureValue = ""
    var parsedTemperatureUnit = ""
    var inTabular = false
    
    // FIXME: - Fetch metode
    
    func getHourlyData(fromURL urlString: String, completion: @escaping ((XMLResult) -> Void)) {
        if let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            
            DispatchQueue.main.async{
                let result = self.beginParsing(urlString: encodedURL)
                completion(result)
            }
        }
    }
    
    //MARK: - XML Parsing
    
    private func beginParsing(urlString: String) -> XMLResult {
        // instantiate parser, that reads through file and reports any tags to its delegate method, after we call parser.parse()
        guard let myURL = URL(string:urlString) else {
            print("URL not defined properly")
            return XMLResult.Failure(error: "Something went with XML parsing")
        }
        guard let parser = XMLParser(contentsOf: myURL) else {
            print("Cannot Read Data")
            return XMLResult.Failure(error: "Cannot Read Data")
        }
        
        parser.delegate = self
        
        if !parser.parse(){ // returns false if errors occured
            print("Data Errors Exist:")
            let error = parser.parserError!
            print("Error Description:\(error.localizedDescription)")
            print("Error reason:\(error.localizedDescription)")
            print("Line number: \(parser.lineNumber)")
            return XMLResult.Failure(error: "Some error occured in XML handling")
        }
        return XMLResult.Success(result: hourDataArray)
    }
    
    // MARK: - Parser Delegate methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // Extract values
        
        switch elementName {
        case "timezone":
            if let offset = attributeDict["utcoffsetMinutes"] {
                parsedOffset = Int(offset)!
            }
        case "tabular":
            inTabular = true
        case "time":
            if inTabular{
                if let from = attributeDict["from"] {
                    parsedTimeFrom = from
                }
                if let to = attributeDict["to"] {
                    parsedTimeTo = to
                }
            }
        case "temperature":
            if let value = attributeDict["value"] {
                parsedTemperatureValue = value
            }
            if let unit = attributeDict["unit"] {
                parsedTemperatureUnit = unit
            }
        default:
            break
            //print("elementName:", elementName)
        }
        currentXMLContent = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //currentXMLContent += string
        currentXMLContent.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName{
        case "tabular":
            inTabular = false
        case "time":
            if inTabular {appendNewHour(to: &hourDataArray)}
        default:
            return
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
//        printResultingHours()
    }
    
    // MARK: Helper methods
    
    
    private func printResultingHours() {
        for hourData in hourDataArray {
            print(hourData)
        }
    }
    
    private func getUNIXTimeFrom8601Format(_ string: String, offsetInMin: Int) -> Double {
        let offsetInSeconds = offsetInMin*60
        let dateTimeFormat = string + "Z"
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: offsetInSeconds)
        let date = formatter.date(from: dateTimeFormat)
        if let UNIXstamp = date?.timeIntervalSince1970 {
            return UNIXstamp} else {
            fatalError("unix conversion error")
        }
    }
    
    private func appendNewHour(to array: inout [YrHourData]) {
        let UNIXFormattedTo = getUNIXTimeFrom8601Format(parsedTimeTo, offsetInMin: parsedOffset)
        let UNIXFormattedFrom = getUNIXTimeFrom8601Format(parsedTimeFrom, offsetInMin: parsedOffset)
        
        let newHour = YrHourData(to: UNIXFormattedTo, from: UNIXFormattedFrom, temperatureUnit: parsedTemperatureUnit, temperatureValue: parsedTemperatureValue)
        
        array.append(newHour)
    }
}
