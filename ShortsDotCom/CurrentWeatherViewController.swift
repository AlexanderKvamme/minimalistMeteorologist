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

var currentWeatherFetchIsFinished = false

let forecastAPIKey = "fdb7fc33b542deec6680877abc34465a"
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
    
    @IBAction func settingsButtonIsTapped(_ sender: AnyObject) {print("Click!")}
    
    @IBOutlet weak var animationView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("kjører currentWeatherViewController")
        
        // Animation
        activityIndicator.stopAnimating()
        activityIndicator.startAnimating()
        
        // Settings
        setUserDefaultsIfInitialRun()
        setupFlowLayout()
        
        // Register observers
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCurrentWeatherStatus), name: NSNotification.Name(rawValue: Notifications.fetchCurrentWeatherDidFinish), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.settingsDidUpdate), name: NSNotification.Name(rawValue: Notifications.settingsDidUpdate), object: nil)
        
        //updateCurrentWeather()
        updateExtendedCurrentWeatherTest()
    }
    func settingsDidUpdate(){
        Animations.playCheckmarkAnimationOnce(inImageView: animationView)
    }
    
    func updateCurrentWeatherStatus(){
        
        self.collectionViewRef.reloadData()
        self.cityAndCountryTextField.text = UserLocation.sharedInstance.locationName
    }
    
    func updateDataSource(newWeather: CurrentWeather){
        
        self.headerImage.image = UIImage(named: newWeather.WeatherIcon.rawValue)
        self.headerText.text = newWeather.summary
        self.cityAndCountryTextField.text = UserLocation.sharedInstance.locationName
        self.cityAndCountryTextField.isHidden = false
        
        tableData = [
            
            myData(firstRowLabel: newWeather.temperatureInPreferredUnit.description, headerInfo: "temperature.png", cellType: cellType.image),
            myData(firstRowLabel: newWeather.windSpeedInPreferredUnit.description, headerInfo: "weathercock.png", cellType: cellType.image),
            myData(firstRowLabel: "Chance of".uppercased(), headerInfo: String(newWeather.precipProbabilityPercentage)+"%", cellType: cellType.text),
            myData(firstRowLabel: newWeather.precipTypeText.uppercased(), headerInfo: newWeather.precipIcon.rawValue, cellType: cellType.image)]
        
        if newWeather.precipProbabilityPercentage == 0 {
            tableData[2].headerInfo = "NO"
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
    
    func updateExtendedCurrentWeatherTest(){
        
        print(" - kjører extendedCurrentWeatherTest)")
        
        forecastClient.fetchExtendedCurrentWeather(currentCoordinate) { apiresult in
            
            self.activityIndicator.startAnimating()
            
            switch apiresult{
                
            case .success(let extendedCurrentWeather):
                
                self.activityIndicator.stopAnimating()
                
                print("printing result if fetchExtendedCurrentWeather")
                print(extendedCurrentWeather)
                
                Animations.playCheckmarkAnimationOnce(inImageView: self.animationView)
                
                //self.updateDataSource(newWeather: extendedCurrentWeather)
                
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

