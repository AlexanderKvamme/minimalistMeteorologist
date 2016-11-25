//
//  ForecastClient.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 05/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation

struct Coordinate{
    var longitude: Double
    var latitude: Double
    
    init(lat: Double, lon: Double){
        longitude = lon
        latitude = lat
    }
}

func createRequestWithCoordinate(_ coordinate: Coordinate) -> URLRequest {
    
    let baseURLString = "https://api.forecast.io/forecast/\(forecastAPIKey)/"
    
    let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")!
    
    let pathString = "\(coordinate.latitude),\(coordinate.longitude)?units=\(currentPreferredUnits.lowercased())"
    
    let endpointString = baseURLString + pathString
    let endpoint = URL(string: endpointString, relativeTo: nil)!
    
    return URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 0)
    
    //TASK: TODO - Sjekk opp i urlkreasjon ved bruk av enum
    
}



class ForecastAPIClient: APIClient {

    let token: String
    let configuration: URLSessionConfiguration
    
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)//lager session etter at configuration har blitt laget
    }()
    
    required init(configuration: URLSessionConfiguration, APIKey: String) {
        self.configuration = configuration
        self.token = APIKey
    }
    
    convenience init(APIKey: String) {
        self.init(configuration: URLSessionConfiguration.default, APIKey: APIKey)
    }
    
    func fetchCurrentWeather(_ coordinate: Coordinate, completion: @escaping (APIResult<CurrentWeather>) -> Void){
        
        // TASK: TODO - Fiks enklere request creation
        let request = createRequestWithCoordinate(coordinate)

        fetch(request: request, parse: { json -> CurrentWeather? in
            
            if let weatherDict = json["currently"] as? [String : AnyObject]{
                
                return CurrentWeather(JSON: weatherDict)
            
            }else {
                print("ERROR: no json returned")
                return nil
            }
            }, completion: completion)
    }
}
