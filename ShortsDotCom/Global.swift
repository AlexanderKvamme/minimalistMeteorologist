

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

