

import UIKit
import Spring

class SettingsViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var settingsView: DesignableView!
    @IBOutlet weak var UnitsOfMeasurementSegmentedControl: UISegmentedControl!
    @IBAction func segmentedDidTouch(_ sender: AnyObject) {
        let index = UnitsOfMeasurementSegmentedControl.selectedSegmentIndex
        
        switch index{
        case 0: defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: index), forKey: "preferredUnits")
        case 1: defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: index), forKey: "preferredUnits")
        case 2: defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: index), forKey: "preferredUnits")
        case 3: defaults.set(UnitsOfMeasurementSegmentedControl.titleForSegment(at: index), forKey: "preferredUnits")
        default: break
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationNames.settingsDidUpdate), object: self)
    }
    
    @IBAction func BackgroundButtonDidTouch(_ sender: AnyObject) {
        settingsView.animation = "fall"
        settingsView.animate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentWithPreferredUnit()
    }

    // MARK: - Helper methods
    
    func setupSegmentWithPreferredUnit(){
        let currentPreferredUnits = defaults.string(forKey: "preferredUnits")!
        
        switch currentPreferredUnits{
        case "SI": UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 0
        case "US": UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 1
        case "UK2": UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 2
        case "CA": UnitsOfMeasurementSegmentedControl.selectedSegmentIndex = 3
        default: print("default")
        }
    }
}

