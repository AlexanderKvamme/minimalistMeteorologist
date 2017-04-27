

import Foundation
import UIKit

// MARK: - Global variables

var currentCoordinate: Coordinate?
let forecastAPIKey = "fdb7fc33b542deec6680877abc34465a"
var forecastClient = ForecastAPIClient(APIKey: forecastAPIKey)
var latestExtendedWeatherFetch = ExtendedCurrentData()

// MARK: - Global Functions

func showAlert(viewController: UIViewController, title: String, message: String, error: NSError?){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(dismissAction)
    viewController.present(alertController, animated: true, completion: nil)
}

// quickPrint

func printTemperatures<T: hasHourlyTemperature>(in arrayOfDoubles: [T]) {
    print("QUICKPRINT: ") 
    var array = [Double]()
    
    for hour in arrayOfDoubles {
        array.append(hour.temperature)
    }
    print(array)
}

func printPrecipitationBools(in hours: [HourData]) {
    var array: [Bool]!
    var b: Bool!
    
    for hour in hours{
        b = hour.isChanceOfPrecipitation
        array.append(b)
    }
    print(array)
}
