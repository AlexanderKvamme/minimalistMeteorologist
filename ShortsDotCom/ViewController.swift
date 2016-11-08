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

let sharedUserLocation = UserLocation.sharedInstance

var GPSCoordinatesLocationIsFinished = false
var reverseGeocodingIsFinished = false
var currentWeatherFetchIsFinished = false

let forecastAPIKey = "fdb7fc33b542deec6680877abc34465a"
var currentCoordinate = Coordinate(lat: 59.911491, lon: 10.757933)
var forecastClient = ForecastAPIClient(APIKey: forecastAPIKey)

// Variables for simultaneous update of reverse geocode and weather

var didReceiveLocation: Bool = false
var didReceiveWeather: Bool = false

// Data source

struct myData { var firstRowLabel: String; var headerInfo: String; var cellType: cellType}
var tableData: [myData] = []

//////////

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

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
    
    @IBOutlet weak var animationView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        activityIndicator.stopAnimating()
        activityIndicator.startAnimating()
        settingsButton.isHidden = false
        setUserDefaultsIfInitialRun()
        
        //observer setup
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUserLocationStatus), name: NSNotification.Name(rawValue: Notifications.userLocationGPSDidUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateReverseGeocodingStatus), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCurrentWeatherStatus), name: NSNotification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        setupFlowLayout()
        
        UserLocation.sharedInstance.updateLocation()
        
        updateCurrentWeather()
    }
    func settingsDidUpdate(){
        Animations.playCheckmarkAnimationOnce(inImageView: animationView)
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
            self.cityAndCountryTextField.text = sharedUserLocation.locationName
        }
        else{
            // do nothing
        }
    }
    
    func updateDataSource(newWeather: CurrentWeather){
        
        self.headerImage.image = UIImage(named: newWeather.WeatherIcon.rawValue)
        self.headerText.text = newWeather.summary
        self.cityAndCountryTextField.text = UserLocation.sharedInstance.locationName
        self.cityAndCountryTextField.isHidden = false
        
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

    // UpdateCurrentWeather
    
    func updateCurrentWeather(){
        
        forecastClient.fetchCurrentWeather(currentCoordinate) { apiresult in
            
            self.activityIndicator.startAnimating()
            
            switch apiresult{
                
            case .success(let currentWeather):
                
                self.activityIndicator.stopAnimating()
                
                Animations.playCheckmarkAnimationOnce(inImageView: self.animationView)
                
                self.updateDataSource(newWeather: currentWeather)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: self)
                
            case .failure(let error as NSError):
                self.activityIndicator.stopAnimating()
                
                showAlert(viewController: self, title: "Error", message: "Could not update weather data. Error: \(error.localizedDescription). \n\n Check your internet connection", error: error)
                
            default: break
            }
        }
    }
    
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
    
    func setupFlowLayout(){
        flowLayout.itemSize.width = (self.view.frame.size.width/2)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
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
}

