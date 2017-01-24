//
//  OnboardingViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 16/01/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    @IBOutlet weak var buttonStack: UIStackView!

    override func viewDidDisappear(_ animated: Bool) {
        print("OnBoardingView did disappear")
    }
    @IBAction func yesButton(_ sender: Any) {
        
        print("yesButton kjøres NÅ")
        print("tapped yes, setting TRUE for willAllowLocationServices")
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "onboardingComplete")
        userDefaults.set(true, forKey: "willAllowLocationServices")
        userDefaults.synchronize()
        
        performSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
    }
    
    @IBAction func noButton(_ sender: Any) {
        
        print("tapped no, setting FALSE for willAllowLocationServices")
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "onboardingComplete")
        userDefaults.set(false, forKey: "willAllowLocationServices")
        userDefaults.synchronize()
    }

    @IBOutlet weak var onboardingView: OnboardingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingView.dataSource = self
        onboardingView.delegate = self
        buttonStack.alpha = 0
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("prepare for segue Ruinning")
    }
    
    // Delegate Functions
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        
        // show buttonstack at index 2
        if index == 2{
            if self.buttonStack.alpha != 1{
                UIView.animate(withDuration: 0.4, animations: {
                    self.buttonStack.alpha = 1
                })
    
            }
        } else {
            if self.buttonStack.alpha != 0{
                UIView.animate(withDuration: 0.4, animations: {
                    self.buttonStack.alpha = 0
                })
            }
        }
    }
    func onboardingDidTransitonToIndex(_ index: Int) {
        //print
    }
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
        //item.
    }
    
    // DataSource functions
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        
        let backgroundColor1 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let backgroundColor2 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let backgroundColor3 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [(
            "onboarding1",
            "Lets get started!",
            "Learn how to get a quick and simple overview of your current weather. \n\nSwipe left to get going!",
            "1test",
            backgroundColor1,
            UIColor.black,
            UIColor.black,
            titleFont,
            descriptionFont),
                
                ("onboarding2", "Shake to refresh!", "To stay up to date, remember to shake your device to fetch the newest weather forecast when you start the application. \n\nNew data available every hour.", "2test", backgroundColor2, UIColor.black, UIColor.black, titleFont, descriptionFont),
                
                ("onboarding3", "Share your location!", "To get started, enable location services so we can see what  weather to fetch for you! \n\n Have fun!", "", backgroundColor3, UIColor.black, UIColor.black, titleFont, descriptionFont)][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
