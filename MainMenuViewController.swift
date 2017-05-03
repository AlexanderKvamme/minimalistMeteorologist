

import UIKit
import CoreLocation
import Spring
import GoogleMaps

/*Runs two fetches from  yr and from darksky.. Darksky is less accurate, so after the darksky data is modelled, replaceDarkSkyHourData() is run to update the first 48 hours with more accurate values, and some additional values such as isChanceOfPrecipitation*/

var midScreen = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)

class MainMenuViewController: UIViewController, CLLocationManagerDelegate {

    //MARK: - Properties
    var yrClient = YrClient()
    var mapView: GMSMapView!
    var mainButton = UIButton()
    var buttonOutline = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var checkmarkView = UIImageView()
    var activityContainer = UIView()
    
    var mainButtonSize: CGFloat = 90
    var animateBackDuration = 0.5
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var shakeToRefreshImage: UIImageView!
    @IBOutlet weak var enableGPSImage: UIImageView!

    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {}

    var isFetching = false
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserDefaultsIfInitialRun()
        setupGoogleMaps()
        setupUIComponents()
        
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

    override func viewWillAppear(_ animated: Bool) {
        setObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIApplication.shared.keyWindow?.rootViewController = self // Stops unwind from "TODAY" from unwinding further back, to Onboarding
    }
    
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
    
    // MARK: - UI Methods

    private func setupUIComponents() {
        makeSettingsButton()
        makeMainButton()
        makeOutlineViewAroundButton()
        makeActivityContainer()
    }
    
    private func makeSettingsButton() {
        let size: CGFloat = 20
        let bottomSpacing: CGFloat = 10
        let btnSize = CGSize(width: size, height: size)
        let position = CGPoint(x: midScreen.x - size/2, y: UIScreen.main.bounds.maxY - size - bottomSpacing)
        
        let btn = UIButton(frame: CGRect(origin: position, size: btnSize))
        btn.setBackgroundImage(UIImage(named: "settingsButton.png"), for: .normal)
        btn.addTarget(self, action: #selector(settingsButtonDidTouch), for: .touchUpInside)
        
        view.addSubview(btn)
    }
    
    private func makeMainButton() {
        mainButton.frame.size = CGSize(width: mainButtonSize, height: mainButtonSize)
        mainButton.center = midScreen
        mainButton.backgroundColor = .black
        mainButton.setTitleColor(.white, for: .normal)
        mainButton.setTitle("GO", for: .normal)
        mainButton.titleLabel?.font = UIFont(name: "Futura", size: 24)
        mainButton.layer.cornerRadius = mainButtonSize/2
        mainButton.addTarget(self, action: #selector(mainButtonDidTouch), for: .touchUpInside)
        view.addSubview(mainButton)
    }
    
    private func makeActivityContainer() {
        
        let size = 40
        
        // Make container
        activityContainer = UIView()
        activityContainer.frame.size = CGSize(width: size, height: size)
        
        // Make activity indicator
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame.size = CGSize(width: size, height: size)
        activityIndicator.isHidden = false
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.color = .black
        
        // Make view to animate checkmark in
        checkmarkView = UIImageView()
        checkmarkView.frame.size = CGSize(width: size, height: size)
        
        // Add to container and view
        activityContainer.addSubview(activityIndicator)
        activityContainer.addSubview(checkmarkView)
        activityContainer.center = midScreen
        view.addSubview(activityContainer)
    }
    
    func makeOutlineViewAroundButton() {
        let outlineWidth: CGFloat = mainButton.frame.width + 20
        let circleCornerRadius = outlineWidth / 2
        
        buttonOutline = UIView(frame: CGRect(x: view.frame.midX - outlineWidth/2,
                                             y: view.frame.midY - outlineWidth/2,
                                             width: outlineWidth,
                                             height: outlineWidth))
        
        buttonOutline.layer.cornerRadius = circleCornerRadius
        buttonOutline.layer.borderColor = UIColor.black.cgColor
        buttonOutline.layer.borderWidth = 5
        buttonOutline.isUserInteractionEnabled = false
        buttonOutline.alpha = 1
        view.addSubview(buttonOutline)
        view.bringSubview(toFront: buttonOutline)
        
    }

    // MARK: - Button handlers
    
    func settingsButtonDidTouch(){
        print("settingsButton did touch")
    }
    
    func mainButtonDidTouch() {
        print("main button did touch")
    }
    
    // MARK: - Animation Methods
    
    private func animateButtonOutline(visible: Bool) {
        
        switch visible {
        case true:
            UIView.animate(withDuration: animateBackDuration, delay: 0, options: .curveEaseInOut, animations: { 
                self.buttonOutline.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            }, completion: { (road) in
                //
            })
       
        case false:
            UIView.animate(withDuration: animateBackDuration, delay: 0.8, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.buttonOutline.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
        }
    }
    
    private func toggleLoadingMode(_ status: Bool){
        
        //view.layoutIfNeeded() // make sure animations complete before triggering a new one
        
        switch status{
        case true:
            animateMainButtonLoading(true)
            
            self.animateButtonOutline(visible: true)
            self.isFetching = true
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.settingsButton.alpha = 0.4
            self.settingsButton.isUserInteractionEnabled = false
            
        case false:
            animateMainButtonLoading(false)
            
            self.animateButtonOutline(visible: false)
            self.isFetching = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.settingsButton.alpha = 1
            self.settingsButton.isUserInteractionEnabled = true
            Animations.playCheckmarkAnimationOnce(inImageView: self.checkmarkView)
        }
    }
    
    private func animateMainButtonLoading(_ b: Bool) {
        let duration = 1.0
        let scale: CGFloat = 0.5

        switch b {
        case true:
            // animate smaller
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                
                self.mainButton.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.mainButton.backgroundColor = .white
                self.mainButton.titleLabel?.alpha = 0
                
            }, completion: { (_) in
                //
            })
            
        case false:
            // animate back
            checkmarkView.stopAnimating()
            
            UIView.animate(withDuration: animateBackDuration, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                
                self.mainButton.transform = CGAffineTransform.identity
                self.mainButton.backgroundColor = .black
            
            }, completion: { (_) in
                self.mainButton.titleLabel?.fadeIn()
            })
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
        print("finished fetching hour data from Yr. handler")
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
        self.shakeToRefreshImage.isHidden = true
        self.enableGPSImage.isHidden = true
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
            showMap(atCoordinate: currentCoordinate!)
            // FIXME: - move into fetchWeather when finished
            // Dette er inni reverseGeocodeHandler, så dette er ETTER vi har returnert resultat. Vi har en
        } else {
            showAlert(viewController: self, title: "Error fetching gps", message: "We can fetch weather for you if you let us access Location Services. Please enable Location Services in your settings and restart the app to update GPS.", error: nil)
        }
    }
    private func showMap(atCoordinate coordinate: Coordinate) {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let userLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let camera = GMSCameraPosition.camera(withTarget: userLocation, zoom: 11)
        let mapFrame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        mapView = GMSMapView.map(withFrame: mapFrame, camera: camera)
        
        // Map Styling
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView.isUserInteractionEnabled = false
        mapView.alpha = 0
        
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        
        UIView.animate(withDuration: 5, animations: {
            self.mapView.alpha = 1
            self.mapView.animate(toZoom: 13)
        }, completion: nil)
    }
    
    // MARK: - Helper methods
    
    private func setupGoogleMaps() {
        GMSServices.provideAPIKey("AIzaSyD18MznE0DNTMCWnTQNVWaYxHUZ8ClXDGE")
    }
    
    private func setupTranslatesAutoresizingMaskIntoConstraints(_ b: Bool) {
        let b = false
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = b
        checkmarkView.translatesAutoresizingMaskIntoConstraints = b
        activityContainer.translatesAutoresizingMaskIntoConstraints = b
        
        mainButton.translatesAutoresizingMaskIntoConstraints = b
        settingsButton.translatesAutoresizingMaskIntoConstraints = b
        shakeToRefreshImage.translatesAutoresizingMaskIntoConstraints = b
        enableGPSImage.translatesAutoresizingMaskIntoConstraints = b
        view.translatesAutoresizingMaskIntoConstraints = b
    }

    func setUserDefaultsIfInitialRun(){
        let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")
        if currentPreferredUnits == nil {
            UserDefaults.standard.set("SI", forKey: "preferredUnits")
        }
    }
    
    // MARK: - API Methods
    
    func fetchWeather(){
        guard let currentCoordinate = currentCoordinate else {
            return
        }
        forecastClient.fetchExtendedCurrentWeather(forCoordinate: currentCoordinate) { apiresult in
            self.toggleLoadingMode(false)
            
            switch apiresult{
            case .success(let result):
                
                // update global variable
                latestExtendedWeatherFetch.currentWeather = result.currentWeather
                latestExtendedWeatherFetch.dailyWeather = result.dailyWeather
                latestExtendedWeatherFetch.hourlyWeather = result.hourlyWeather
                
                self.replaceDarkSkyHourData()
                
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
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                self.toggleLoadingMode(true)
                showAlert(viewController: self, title: "Error fetching data", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
            default: break
            }
        }
    }
    
    func replaceDarkSkyHourData() {
        // The first 48 hours are available from yr and are much more accurate than DarkSky, so here the first hours from Darksky are replaced with the avaiable hourData from yr. (The first 48 hours). Replaces temperatures and precipitation
        guard let yrHours = latestExtendedWeatherFetch.hourlyWeatherFromYr else {
            print("\nERROR: no yrHours stored in global value 'latestExtendedWeatherFetch'. Exiting replaceDarkSkyHourData")
            return
        }
        
        for i in 0 ..< yrHours.count {
            if hourHasPrecipitation(yrHours[i]) {
                latestExtendedWeatherFetch.hourlyWeather?[i].isChanceOfPrecipitation = true
            }
            
            latestExtendedWeatherFetch.hourlyWeather?[i].temperature = (latestExtendedWeatherFetch.hourlyWeatherFromYr?[i].temperature)!
        }
    }
    
    func hourHasPrecipitation(_ hour: YrHourData) -> Bool {
        
        if hour.precipitationMinValue != nil && hour.precipitationMaxValue != nil {
            return true
        }
        return false
    }
    
    func fetchWeatherFromYr(){
        // This is run from the reverseGeocodeHandler after updating self.currentLocation so the location data is available in the UserLocation singleton
        // Format reverseGeocode location to a XML request and send to yr.no
        
        let country = UserLocation.sharedInstance.country
        let adminArea = UserLocation.sharedInstance.administrativeArea
        let locality = UserLocation.sharedInstance.locality
        let subLocality = UserLocation.sharedInstance.subLocality
        
        //if country == nil || adminArea == nil || locality == nil || subLocality == nil {
        if country == nil || adminArea == nil || locality == nil {
            print("Not enough geodata to construct Yr request")
            return
        }
        
        let urlString = "http://www.yr.no/place/\(country)/\(adminArea)/\(locality)/\(subLocality)/forecast_hour_by_hour.xml"
        print("yr request: ", urlString)
        
        yrClient.fetchHourlyDataFromYr(URL: urlString) { (result) in
            switch result {
            case .Success(let resultingYrData):
                
                latestExtendedWeatherFetch.hourlyWeatherFromYr = resultingYrData // update global value (to let Charts access it)
                
                // post notifications
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.userLocationGPSDidUpdate), object: self)
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.fetchWeatherFromYrDidFinish), object: self)
                
            case .Failure(let e):
                print("i got back failure with e: \(e)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.fetchWeatherFromYrFailed), object: self)
            }
        }
    }
}

