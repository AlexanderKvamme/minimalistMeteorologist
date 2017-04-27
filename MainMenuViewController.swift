

import UIKit
import CoreLocation
import Spring

class MainMenuViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: - Properties
    var yrClient = YrClient()
    
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var checkmarkView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var shakeToRefreshImage: UIImageView!
    @IBOutlet weak var enableGPSImage: UIImageView!
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {}
    
    var isFetching = false
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserDefaultsIfInitialRun()
        buttonStack.isUserInteractionEnabled = false
        todayButton.layer.borderWidth = 2
        todayButton.layer.borderColor = UIColor.black.cgColor
        if UserDefaults.standard.bool(forKey: "willAllowLocationServices"){
            toggleLoadingMode(true)
            UserLocation.sharedInstance.updateLocation()
        } else {
            isFetching = false
            toggleLoadingMode(true)
            shakeToRefreshImage.isHidden = false
            enableGPSImage.isHidden = false
        }
    }
    
    // MARK: - viewWillAppear - Set Observers

    override func viewWillAppear(_ animated: Bool) {
        setObservers()
    }
    
    // MARK: - viewDidDisappear - update rootViewController
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.rootViewController = self // Stops unwind from "TODAY" from unwinding further back, to Onboarding
    }
    
    // MARK: - motionBegan
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if UserDefaults.standard.bool(forKey: "willAllowLocationServices") && isFetching == false {
            toggleLoadingMode(true)
            UserLocation.sharedInstance.updateLocation() // this will then fetch new weather after gps update
        } else {
            let missingLocationServicesAlert = UIAlertController(title: "Location Services needed", message: "In order to provide you with the latest local weather, you need to give us access to your location!", preferredStyle: UIAlertControllerStyle.alert)
            missingLocationServicesAlert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.cancel, handler: nil))
            missingLocationServicesAlert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                UserDefaults.standard.setValue(true, forKey: "willAllowLocationServices")
                UserDefaults.standard.synchronize()
                UserLocation.sharedInstance.updateLocation()
            }))
            present(missingLocationServicesAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Helper Methods

    func fetchWeather(){
        guard let currentCoordinate = currentCoordinate else {
            return
        }
        forecastClient.fetchExtendedCurrentWeather(forCoordinate: currentCoordinate) { apiresult in
            self.toggleLoadingMode(false)
            
            switch apiresult{
            case .success(let result):
                
                print("Success: darksky hourly fra result.hourlyWeather.temp: ")
                var temp = [Double]()
                for hour in result.hourlyWeather! {
                    temp.append(hour.temperature)
                }
                print(temp)
                
                // update global variable
                latestExtendedWeatherFetch.currentWeather = result.currentWeather
                latestExtendedWeatherFetch.dailyWeather = result.dailyWeather
                latestExtendedWeatherFetch.hourlyWeather = result.hourlyWeather
                
                // FIXME: - complete these
                self.replaceDarkSkyHourDataWithAvaiableHourFromYr()
                
                print("timer fra extended.hourlyWeatherFromYr!")
                print("FIXME: timene har ikke blitt oppdatert i denne closuren, kanskje fordi den har kopiert en instance av globalen?")
                var temp2 = [Double]()
                for hour in latestExtendedWeatherFetch.hourlyWeatherFromYr! {
                    temp2.append(hour.temperature)
                }
                print(temp2)
                print()
                
                
                if let
                    fetchedDays = latestExtendedWeatherFetch.dailyWeather,
                    let fetchedHours = latestExtendedWeatherFetch.hourlyWeather {
                    
                    var dayIndex = 0
                    var organizedHours = [HourData]()
                    for hour in fetchedHours where dayIndex < fetchedDays.count {
                        if hour.dayNumber == fetchedDays[dayIndex].dayNumber {
                            organizedHours.append(hour)
                        } else{
                            latestExtendedWeatherFetch.dailyWeather![dayIndex].hourData = organizedHours
                            organizedHours.removeAll()
                            dayIndex += 1
                        }
                    }
                }
                
                print ("FØR fetchDidFinishHandler kalles")
                print ("")
                var temp3 = [Double]()
                for hour in latestExtendedWeatherFetch.hourlyWeather! {
                    temp3.append(hour.temperature)
                }
                print(temp3)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                self.toggleLoadingMode(true)
                showAlert(viewController: self, title: "Error fetching data", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
            default: break
            }
        }
    }
    
    func replaceDarkSkyHourDataWithAvaiableHourFromYr() {
        // The first 48 hours are available from yr and are much more accurate than DarkSky, so here the first hours from Darksky are replaced with the avaiable hourData from yr. (The first 48 hours)
        guard var yrHours = latestExtendedWeatherFetch.hourlyWeatherFromYr, var darkSkyHours = latestExtendedWeatherFetch.hourlyWeather else {
            print("no yrHours stored in global value 'latestExtendedWeatherFetch' yet.")
            return
        }

        for i in 0 ..< yrHours.count {
            print("gonna change \(latestExtendedWeatherFetch.hourlyWeather?[i].temperature) updated to yrs value of: \(latestExtendedWeatherFetch.hourlyWeatherFromYr?[i].temperature)")
        
            latestExtendedWeatherFetch.hourlyWeather?[i].temperature = (latestExtendedWeatherFetch.hourlyWeatherFromYr?[i].temperature)!
            
        }
        
        
        print ("I SLUTTEN AV replaceDarkSkyHourDataWithAvaiableHourFromYr ")
        print ("")
        var temp3 = [Double]()
        for hour in latestExtendedWeatherFetch.hourlyWeather! {
            temp3.append(hour.temperature)
        }
        print(temp3)
    }
    
    func fetchWeatherFromYr(){
        // This is run from the reverseGeocodeHandler after updating self.currentLocation so the location data is available in the UserLocation singleton
        // Format reverseGeocode location to a XML request and send to yr.no
        
        let country = UserLocation.sharedInstance.country
        let adminArea = UserLocation.sharedInstance.administrativeArea
        let locality = UserLocation.sharedInstance.locality
        let subLocality = UserLocation.sharedInstance.subLocality
        
        let urlString = "http://www.yr.no/place/\(country)/\(adminArea)/\(locality)/\(subLocality)/forecast_hour_by_hour.xml"

        yrClient.fetchHourlyDataFromYr(URL: urlString) { (result) in
            switch result {
            case .Success(let resultingYrData):
                // FIXME: - Use the Hours
                latestExtendedWeatherFetch.hourlyWeatherFromYr = resultingYrData
                
//                latestExtendedWeatherFetch!.dailyWeather![dayIndex].hourData = organizedHours
                print("SUCCESS: result received in main menu")
                print("SUCCESS count: ", resultingYrData.count)
                  NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.userLocationGPSDidUpdate), object: self)
                  NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.fetchWeatherFromYrDidFinish), object: self)
//                print("with r: \(r)")
            case .Failure(let e):
                print("i got back failure with e: \(e)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.fetchWeatherFromYrFailed), object: self)
            }
        }
    }
    
    func toggleLoadingMode(_ status: Bool){
        switch status{
        case true:
            self.isFetching = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.buttonStack.alpha = 0.4
            self.settingsButton.alpha = 0.4
            self.buttonStack.isUserInteractionEnabled = false
            self.settingsButton.isUserInteractionEnabled = false
            
        case false:
            self.isFetching = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.buttonStack.alpha = 1
            self.settingsButton.alpha = 1
            self.buttonStack.isUserInteractionEnabled = true
            self.settingsButton.isUserInteractionEnabled = true
            Animations.playCheckmarkAnimationOnce(inImageView: self.checkmarkView)
        }
    }
    
    func setObservers(){
        // Location based
        NotificationCenter.default.addObserver(self, selector: #selector(locationManagerFailedHandler), name: NSNotification.Name(rawValue: NotificationNames.locationManagerFailed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reverseGeocodeFinishedHandler), name: NSNotification.Name(rawValue: NotificationNames.reverseGeocodingDidFinish), object: nil)
        
        // Networking
        NotificationCenter.default.addObserver(self, selector: #selector(fetchDidFinishHandler), name: NSNotification.Name(rawValue: NotificationNames.fetchCurrentWeatherDidFinish), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromDarkSkyFailed), name: NSNotification.Name(rawValue: NotificationNames.fetchCurrentWeatherDidFail), object: nil)
        
        // Yr
        NotificationCenter.default.addObserver(self, selector: #selector(fetchWeatherFromYrDidFinishHandler), name: NSNotification.Name(rawValue: NotificationNames.fetchWeatherFromYrDidFinish), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchWeatherFromYrFailedHandler), name: NSNotification.Name(rawValue: NotificationNames.fetchWeatherFromYrFailed), object: nil)

        // System
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidUpdate), name: NSNotification.Name(rawValue: NotificationNames.settingsDidUpdate), object: nil)
    }
    
    // MARK: - Handlers for observers
    func fetchWeatherFromYrDidFinishHandler(){
        print("finished fetching hour data from Yr handler")
    }
    
    func fetchWeatherFromYrFailedHandler(){
        print("Failed fetching hours from Yr")
    }
    
    func fetchFromDarkSkyFailed() {
        if self.presentedViewController == nil {
            showAlert(viewController: self, title: "Server denied fetch", message: "Please try again later", error: nil)
        }
    }
    
    func fetchDidFinishHandler(){
        print("fetch finished")
        self.shakeToRefreshImage.isHidden = true
        self.enableGPSImage.isHidden = true
        
        print ("fetchDidFinishHandler temperaturer")
        print ("feile temperaturer her igjen... Kan være det er noe med capture list og sånn i closuren")
        var temp = [Double]()
        for hour in latestExtendedWeatherFetch.hourlyWeather! {
            temp.append(hour.temperature)
        }
        print(temp)
    }

    func locationManagerFailedHandler(){
        self.enableGPSImage.isHidden = false
    }
    
    func settingsDidUpdate(){
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        fetchWeather()
    }

    func reverseGeocodeFinishedHandler(){
        if let latestGPS = UserLocation.sharedInstance.coordinate{
            currentCoordinate = latestGPS
            fetchWeather()
            fetchWeatherFromYr()
            // FIXME: - move into fetchWeather when finished
            // Dette er inni reverseGeocodeHandler, så dette er ETTER vi har returnert resultat. Vi har en
        } else {
            showAlert(viewController: self, title: "Error fetching gps", message: "We can fetch weather for you if you let us access Location Services. Please enable Location Services in your settings and restart the app to update GPS.", error: nil)
        }
    }
}


// MARK: - Helper methods

func setUserDefaultsIfInitialRun(){
    let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")
    if currentPreferredUnits == nil {
        UserDefaults.standard.set("SI", forKey: "preferredUnits")
    }
}

