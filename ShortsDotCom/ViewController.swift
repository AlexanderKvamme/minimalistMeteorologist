//
//  ViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 01/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// Animation setup

var loading_00000: UIImage!
var loading_00001: UIImage!
var loading_00002: UIImage!
var loading_00003: UIImage!
var loading_00004: UIImage!
var loading_00005: UIImage!
var loading_00006: UIImage!
var loading_00007: UIImage!
var loading_00008: UIImage!
var loading_00009: UIImage!
var loading_00010: UIImage!
var loading_00011: UIImage!
var loading_00012: UIImage!
var loading_00013: UIImage!
var loading_00014: UIImage!
var loading_00015: UIImage!
var loading_00016: UIImage!
var loading_00017: UIImage!
var loading_00018: UIImage!
var loading_00019: UIImage!
var loading_00020: UIImage!
var loading_00021: UIImage!
var loading_00022: UIImage!
var loading_00023: UIImage!
var loading_00024: UIImage!
var loading_00025: UIImage!
var loading_00026: UIImage!
var loading_00027: UIImage!
var loading_00028: UIImage!
var loading_00029: UIImage!
var loading_00030: UIImage!
var loading_00031: UIImage!
var loading_00032: UIImage!
var loading_00033: UIImage!
var loading_00034: UIImage!
var loading_00035: UIImage!
var loading_00036: UIImage!
var loading_00037: UIImage!
var loading_00038: UIImage!
var loading_00039: UIImage!
var loading_00040: UIImage!
var loading_00041: UIImage!
var loading_00042: UIImage!
var loading_00043: UIImage!
var loading_00044: UIImage!
var loading_00045: UIImage!
var loading_00046: UIImage!
var loading_00047: UIImage!
var loading_00048: UIImage!
var loading_00049: UIImage!
var loading_00050: UIImage!
var loading_00051: UIImage!
var loading_00052: UIImage!
var loading_00053: UIImage!
var loading_00054: UIImage!
var loading_00055: UIImage!
var loading_00056: UIImage!
var loading_00057: UIImage!
var loading_00058: UIImage!
var loading_00059: UIImage!
var loading_00060: UIImage!
var loading_00061: UIImage!
var loading_00062: UIImage!
var loading_00063: UIImage!
var loading_00064: UIImage!
var loading_00065: UIImage!
var loading_00066: UIImage!
var loading_00067: UIImage!
var loading_00068: UIImage!
var loading_00069: UIImage!
var loading_00070: UIImage!
var loading_00071: UIImage!
var loading_00072: UIImage!
var loading_00073: UIImage!
var loading_00074: UIImage!
var loading_00075: UIImage!
var loading_00076: UIImage!
var loading_00077: UIImage!
var loading_00078: UIImage!
var loading_00079: UIImage!

// Global variables
var GPSCoordinatesLocationIsFinished = false
var reverseGeocodingIsFinished: Bool = false
var currentWeatherFetchIsFinished: Bool = false

// API

let forecastAPIKey = "fdb7fc33b542deec6680877abc34465a"
var currentCoordinate = Coordinate(lat: 59.911491, lon: 10.757933)
var forecastClient = ForecastAPIClient(APIKey: forecastAPIKey)

// Location variables

var latitude = 0.0
var longitude = 0.0

// Variables for simultaneous update of reverse geocode and weather

var didReceiveLocation: Bool = false
var didReceiveWeather: Bool = false

// Data source

struct myData { var firstRowLabel: String; var headerInfo: String; var cellType: cellType}
var tableData: [myData] = []

//////////

//////////

//////////

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {//setter ViewController som datasource og delegate

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionViewRef: UICollectionView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var cityAndCountryTextField: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonIsTapped(_ sender: AnyObject) {
        print("Click!")
    }
    
    // Location
    
    let sharedUserLocation = UserLocation.sharedInstance
    
    // Animation setup
    
    @IBOutlet weak var animationView: UIImageView!
    var checkmarkImages: [UIImage]!
    
    func setupAnimation(){
        loading_00040 = UIImage(named: "loading_00040.png")
        loading_00041 = UIImage(named: "loading_00041.png")
        loading_00042 = UIImage(named: "loading_00042.png")
        loading_00043 = UIImage(named: "loading_00043.png")
        loading_00044 = UIImage(named: "loading_00044.png")
        loading_00045 = UIImage(named: "loading_00045.png")
        loading_00046 = UIImage(named: "loading_00046.png")
        loading_00047 = UIImage(named: "loading_00047.png")
        loading_00048 = UIImage(named: "loading_00048.png")
        loading_00049 = UIImage(named: "loading_00049.png")
        loading_00050 = UIImage(named: "loading_00050.png")
        loading_00051 = UIImage(named: "loading_00051.png")
        loading_00052 = UIImage(named: "loading_00052.png")
        loading_00053 = UIImage(named: "loading_00053.png")
        loading_00054 = UIImage(named: "loading_00054.png")
        loading_00055 = UIImage(named: "loading_00055.png")
        loading_00056 = UIImage(named: "loading_00056.png")
        loading_00057 = UIImage(named: "loading_00057.png")
        loading_00058 = UIImage(named: "loading_00058.png")
        loading_00059 = UIImage(named: "loading_00059.png")
        loading_00060 = UIImage(named: "loading_00060.png")
        loading_00061 = UIImage(named: "loading_00061.png")
        loading_00062 = UIImage(named: "loading_00062.png")
        loading_00063 = UIImage(named: "loading_00063.png")
        loading_00064 = UIImage(named: "loading_00064.png")
        loading_00065 = UIImage(named: "loading_00065.png")
        loading_00066 = UIImage(named: "loading_00066.png")
        loading_00067 = UIImage(named: "loading_00067.png")
        loading_00068 = UIImage(named: "loading_00068.png")
        loading_00069 = UIImage(named: "loading_00069.png")
        loading_00070 = UIImage(named: "loading_00070.png")
        loading_00071 = UIImage(named: "loading_00071.png")
        loading_00072 = UIImage(named: "loading_00072.png")
        loading_00073 = UIImage(named: "loading_00073.png")
        loading_00074 = UIImage(named: "loading_00074.png")
        loading_00075 = UIImage(named: "loading_00075.png")
        loading_00076 = UIImage(named: "loading_00076.png")
        loading_00077 = UIImage(named: "loading_00077.png")
        loading_00078 = UIImage(named: "loading_00078.png")
        loading_00079 = UIImage(named: "loading_00079.png")
        
        checkmarkImages = [loading_00040, loading_00041, loading_00042, loading_00043, loading_00044, loading_00045, loading_00046, loading_00047, loading_00048, loading_00049, loading_00050, loading_00051, loading_00052, loading_00053, loading_00054, loading_00055, loading_00056, loading_00057, loading_00058, loading_00059, loading_00060, loading_00061, loading_00062, loading_00063, loading_00064, loading_00065, loading_00066, loading_00067, loading_00068, loading_00069, loading_00070, loading_00071, loading_00072, loading_00073, loading_00074, loading_00075, loading_00076, loading_00077, loading_00078, loading_00079]
    }
    
    func playCheckmarkOnce(){
        
        animationView.animationImages = checkmarkImages
        animationView.animationDuration = 1
        animationView.animationRepeatCount = 1
        animationView.startAnimating()
    }
    
    func playCheckmarkAnimation(){
        setupAnimation()
        playCheckmarkOnce()
    }
    
    // Flow layout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        if tableData[indexPath.row].cellType == .text {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCellPrototypeText", for: indexPath) as! MyCollectionViewCellPercent

            cell.textFieldPrototype.text = tableData[indexPath.row].firstRowLabel
            cell.textFieldHeader.text = tableData[indexPath.row].headerInfo
            cell.textFieldHeader.textAlignment = .center
            return cell
        } else {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCellPrototypeImage", for: indexPath) as! MyCollectionViewCell
        
            cell.textFieldPrototype.text = tableData[indexPath.row].firstRowLabel
            let imageName = UIImage(named: tableData[indexPath.row].headerInfo)
            cell.imageViewPrototype.image = imageName
            return cell
        }
    }

    func updateDataSource(newWeather: CurrentWeather){
        
        self.headerImage.image = UIImage(named: newWeather.WeatherIcon.rawValue)
        self.headerText.text = newWeather.summary
        self.cityAndCountryTextField.text = UserLocation.sharedInstance.locationName
        
            tableData = [
                
                // temperature cell
                myData(firstRowLabel: newWeather.temperatureWithUnit.description, headerInfo: "temperature.png", cellType: cellType.image),
                
                // windspeed cell
                myData(firstRowLabel: newWeather.windSpeedWithUnit.description, headerInfo: "weathercock.png", cellType: cellType.image),
                
                // precipitation chance cell
                myData(firstRowLabel: "Chance of", headerInfo: String(newWeather.precipProbabilityPercentage)+"%", cellType: cellType.text),
                
                // precipitation symbol cell
                myData(firstRowLabel: newWeather.precipTypeText, headerInfo: newWeather.precipIcon.rawValue, cellType: cellType.image)]
        
        if newWeather.precipProbabilityPercentage == 0 {
            tableData[2].headerInfo = "No"
        }
        
    }
    
    
    //////////
    
    //////////
    
    //////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        activityIndicator.stopAnimating()
        activityIndicator.startAnimating()
        settingsButton.isHidden = false
        setUserDefaultsIfInitialRun()
        
        //observer setup
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUserLocationStatus), name: NSNotification.Name(rawValue: Notifications.userLocationGPSDidUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateReverseGeocodingStatus), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinished), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCurrentWeatherStatus), name: NSNotification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidLoad), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        setupFlowLayout()
        
        UserLocation.sharedInstance.updateLocation()
        
        updateCurrentWeather()
    }
    func settingsDidUpdate(){
        playCheckmarkOnce()
    }
    
    func updateUserLocationStatus(){
        
        GPSCoordinatesLocationIsFinished = true
        dataCollectedCheck()
    }
    
    func updateReverseGeocodingStatus(){
    
        reverseGeocodingIsFinished = true
        dataCollectedCheck()
    }
    
    func updateCurrentWeatherStatus(){
        currentWeatherFetchIsFinished = true
        dataCollectedCheck()
    }
    
    func dataCollectedCheck(){
        
        if(currentWeatherFetchIsFinished && reverseGeocodingIsFinished && GPSCoordinatesLocationIsFinished){
            
            self.collectionViewRef.reloadData()
            
            reverseGeocodingIsFinished = false
            currentWeatherFetchIsFinished = false
            GPSCoordinatesLocationIsFinished = false
            
            self.cityAndCountryTextField.isHidden = false
        }
        else{
            // do nothing
        }
    }

    // UpdateCurrentWeather
    
    func updateCurrentWeather(){
        
        forecastClient.fetchCurrentWeather(currentCoordinate) { apiresult in
            
            self.activityIndicator.startAnimating()
            
            switch apiresult{
                
            case .success(let currentWeather):
                
                self.activityIndicator.stopAnimating()
                self.playCheckmarkAnimation()
                
                self.updateDataSource(newWeather: currentWeather)
                
                // Post notification
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                self.activityIndicator.stopAnimating()
                
                self.showAlert(title: "Error", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
                
            default: break
            }
        }
    }
    
    // Reactive functions
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        self.viewDidLoad()
    }
    
    func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        settingsButton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
    // Helper functions
    
    func showAlert(title: String, message: String, error: NSError?){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setupFlowLayout(){
        flowLayout.itemSize.width = (self.view.frame.size.width/2)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
    }
    
    // Setting standard userPref if first time run
    
    func setUserDefaultsIfInitialRun(){
        
        let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")
        
        if currentPreferredUnits == nil {
            UserDefaults.standard.set("SI", forKey: "preferredUnits")
        }
    }
}

