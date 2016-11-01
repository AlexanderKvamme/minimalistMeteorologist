//
//  Global.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 31/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

// showAlert()
// setUserDefaultsIfInitialRun()
//

func showAlert(viewController: UIViewController, title: String, message: String, error: NSError?){
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(dismissAction)
    
    viewController.present(alertController, animated: true, completion: nil)
}

// Setting standard userPref if first time run

func setUserDefaultsIfInitialRun(){
    
    let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")
    
    if currentPreferredUnits == nil {
        UserDefaults.standard.set("SI", forKey: "preferredUnits")
    }
}

