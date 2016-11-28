//
//  SettingsViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 17/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var settingsView: DesignableView!
    @IBOutlet weak var UnitsOfMeasurementSegmentedControl: UISegmentedControl!
    
    //Action buttons
    
    @IBAction func segmentedDidTouch(_ sender: AnyObject) {
        
        switch UnitsOfMeasurementSegmentedControl.selectedSegmentIndex{
            
        case 0:
            defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: UnitsOfMeasurementSegmentedControl.selectedSegmentIndex), forKey: "preferredUnits")
            
        case 1:
            defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: UnitsOfMeasurementSegmentedControl.selectedSegmentIndex), forKey: "preferredUnits")
            
        case 2:
            defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: UnitsOfMeasurementSegmentedControl.selectedSegmentIndex), forKey: "preferredUnits")
            
        case 3:
            defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: UnitsOfMeasurementSegmentedControl.selectedSegmentIndex), forKey: "preferredUnits")
            
        default:
            print("default selected")
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.settingsDidUpdate), object: self)
    }
    
    @IBAction func BackgroundButtonDidTouch(_ sender: AnyObject) {
        
        settingsView.animation = "fall"
        settingsView.animate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentWithPreferredUnit()
    }

    // Helper methods
    
    func setupSegmentWithPreferredUnit(){
        
        let currentPreferredUnits = defaults.string(forKey: "preferredUnits")!
        
        switch currentPreferredUnits{
            
        case "SI":
            UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 0
            
        case "US":
            UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 1
            
        case "UK2":
            UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 2
            
        case "CA":
            UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 3
            
        default:
            print("default")
        }
        
    }
}
