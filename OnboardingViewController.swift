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

    @IBAction func yesButton(_ sender: Any) {
        print("set global flag 'didAllowGPS' or something")
    }
    @IBAction func noButton(_ sender: Any) {
        print("set global flag 'didAllowGPS' or something")
    }

    
    @IBOutlet weak var onboardingView: OnboardingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onboardingView.dataSource = self
        onboardingView.delegate = self
        buttonStack.alpha = 0
        
        // Do any additional setup after loading the view.
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
        //bam
    }
    
    // DataSource functions
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        
        let backgroundColor1 = UIColor(red: 217/255, green: 72/255, blue: 89/255, alpha: 1)
        let backgroundColor2 = UIColor(red: 200/255, green: 72/255, blue: 89/255, alpha: 1)
        let backgroundColor3 = UIColor(red: 180/255, green: 72/255, blue: 89/255, alpha: 1)
        
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [(
            "onboardingScreen1", "Welcome!", "blabla lots of text goes here check it out", "test", backgroundColor1, UIColor.white, UIColor.white, titleFont, descriptionFont),
                
                ("onboardingScreen2", "Shake it up", "blabla lots of text goes here check it out", "test", backgroundColor2, UIColor.white, UIColor.white, titleFont, descriptionFont),
                
                ("onboardingScreen3", "Lets get started!", "blabla lots of text goes here check it out", "", backgroundColor3, UIColor.white, UIColor.white, titleFont, descriptionFont)][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
