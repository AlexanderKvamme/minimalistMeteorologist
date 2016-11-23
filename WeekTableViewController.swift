//
//  WeekTableViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

class WeekTableViewController: UITableViewController, UIGestureRecognizerDelegate{

    //Variables
    var weekArray = [Int]()
    var currentWeekIsAtIndex = Int()
    var currentWeekIndexPath = Int()
    var currentlySelectedWeek = Int()
    
    // MARK: Outlets and actions
    
    @IBAction func didSwipeRight(_ sender: AnyObject) {}
    @IBOutlet var swipeRightRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var swipeLeftRecognizer: UISwipeGestureRecognizer!
    @IBAction func didSwipeLeft(_ sender: AnyObject) {
        print("didSwipeLeft")
        self.performSegue(withIdentifier: "WeekTableToDetailed", sender: self)
    }
    @IBAction func unwindToWeeks(segue: UIStoryboardSegue) {}

    
    // Mark: Snap behavior in scrolling
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        print("scrollViewWillEndDraging")
        
            //tableView.autoSnapping(velocity: velocity, targetOffset: targetContentOffset)
    }
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("didEndScrollingAnimation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for week in 1...52{
            weekArray.append(week)
        }
        
        currentWeekIsAtIndex = getCurrentWeekNumber()-1
        let currentWeekIndexPath = IndexPath(row: currentWeekIsAtIndex, section: 0)
        tableView.scrollToRow(at: currentWeekIndexPath, at: .middle, animated: true)
    }
    
    // Pass data to WeeksDetailedTableViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "WeeksTableToDetailed") {
            let destination = segue.destination as! WeeksDetailedTableViewController
            destination.weekNumber = currentlySelectedWeek
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        currentlySelectedWeek = indexPath.row + 1
        
        let cellIdentifier = "WeekTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WeekTableViewCell

        cell.weekNumberLabel!.text = String(weekArray[indexPath.row])
        
        // set currentWeek
        if cell.weekNumberLabel!.text == String(getCurrentWeekNumber()){
  
            cell.currentWeekLabel.isHidden = false
        } else {
            cell.currentWeekLabel.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: Gesture settings
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
