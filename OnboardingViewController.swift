

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {

    // MARK: - Outlets And Buttons
    
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var onboardingView: OnboardingView!
    @IBAction func yesButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "willAllowLocationServices")
        UserDefaults.standard.synchronize()
        performSegue(withIdentifier: "onboardingToMainMenu", sender: self)
    }
    
    @IBAction func noButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(false, forKey: "willAllowLocationServices")
        UserDefaults.standard.synchronize()
        performSegue(withIdentifier: "onboardingToMainMenu", sender: self)
    }

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        onboardingView.dataSource = self
        onboardingView.delegate = self
        buttonStack.alpha = 0
    }
    
    // MARK: - Paper Onboarding Delegate Methods
    
    public func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {}
    public func onboardingDidTransitonToIndex(_ index: Int) {}
    
    // Button Fade in/out
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 2 {
            UIView.animate(withDuration: 0.4, animations: { self.buttonStack.alpha = 1 })
        } else {
            UIView.animate(withDuration: 0.4, animations: { self.buttonStack.alpha = 0 })
        }
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColor1 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let backgroundColor2 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let backgroundColor3 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 24)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 18)!
        
        return [(
            "onboarding1", "Lets get started!", "Learn how to get a quick and simple overview of your current weather. \n\nSwipe left to get going!", "1test", backgroundColor1, UIColor.black, UIColor.black, titleFont, descriptionFont),
                
                ("onboarding2", "Shake to refresh!", "To stay up to date, remember to shake your device to fetch the newest weather forecast when you start the application. \n\nNew data available every hour.", "2test", backgroundColor2, UIColor.black, UIColor.black, titleFont, descriptionFont),
                
                ("onboarding3", "Share your location!", "To get started, enable location services so we can see what  weather to fetch for you! \n\n Have fun!", "", backgroundColor3, UIColor.black, UIColor.black, titleFont, descriptionFont)][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
}

