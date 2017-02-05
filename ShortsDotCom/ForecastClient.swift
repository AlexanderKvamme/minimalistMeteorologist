

import Foundation

// MARK: - Properties

struct Coordinate{
    var longitude: Double
    var latitude: Double
    
    init(lat: Double, lon: Double){
        longitude = lon
        latitude = lat
    }
}

// MARK: - Methods

// Mark: - Request For Current weather

func createRequestWithCoordinate(_ coordinate: Coordinate) -> URLRequest {
    let baseURLString = "https://api.forecast.io/forecast/\(forecastAPIKey)/"
    let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")!
    let pathString = "\(coordinate.latitude),\(coordinate.longitude)?units=\(currentPreferredUnits.lowercased())"
    let endpointString = baseURLString + pathString
    let endpoint = URL(string: endpointString, relativeTo: nil)!
    
    return URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 0)
}

// Mark: - Request For Extended Current Weather

func createExtendedRequestWithCoordinate(_ coordinate: Coordinate) -> URLRequest {
    let baseURLString = "https://api.forecast.io/forecast/\(forecastAPIKey)/"
    let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")!
    let pathString = "\(coordinate.latitude),\(coordinate.longitude)?units=\(currentPreferredUnits.lowercased())&extend=hourly"
    let endpointString = baseURLString + pathString
    let endpoint = URL(string: endpointString, relativeTo: nil)!
    
    return URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 0)
}

// MARK: - API Client

class ForecastAPIClient: APIClient {
    let token: String
    let configuration: URLSessionConfiguration
    
    lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    required init(configuration: URLSessionConfiguration, APIKey: String) {
        self.configuration = configuration
        self.token = APIKey
    }
    
    convenience init(APIKey: String) {
        self.init(configuration: URLSessionConfiguration.default, APIKey: APIKey)
    }
    
    // Extended Version of fetchCurrentWeahter()
    
    func fetchExtendedCurrentWeather(forCoordinate coordinate: Coordinate, completion: @escaping (APIResult<ExtendedCurrentData>) -> Void){
        let request = createExtendedRequestWithCoordinate(coordinate)
        fetch(request: request, parse: { json -> ExtendedCurrentData? in
             if let fullWeatherDict = json as? [String : AnyObject] {
                return ExtendedCurrentData(JSON:fullWeatherDict)
             }
             else {
                return nil
             }
        }, completion: completion)
    }
}

