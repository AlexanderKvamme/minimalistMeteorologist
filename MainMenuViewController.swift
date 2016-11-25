//
//  MainMenuViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 24/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import CoreLocation

class MainMenuViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBAction func unwindToMainMenu(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reverseGeocodeHandler), name: NSNotification.Name(rawValue: Notifications.reverseGeocodingDidFinish), object: nil)
        
        UserLocation.sharedInstance.updateLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reverseGeocodeHandler(){
        print("geocode updated")
    }
    
}
