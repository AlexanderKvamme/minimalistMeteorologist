//
//  WeekTableViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

class WeekTableViewController: UITableViewController, UIGestureRecognizerDelegate{

    // MARK: - Properties
    
    var weekArray = [Int]()
    var currentWeekIsAtIndex = Int()
    var currentWeekIndexPath = Int()
    var currentlySelectedWeek = Int()
    
    @IBAction func unwindToWeeks(segue: UIStoryboardSegue) {}
    
    // Mark: - Snap behavior in scrolling
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        tableView.autoSnapping(velocity: velocity, targetOffset: targetContentOffset)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("didEndScrollingAnimation - snap to something")
    }
    
    // Mark: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for week in 1...52{
            weekArray.append(week)
        }
        
        currentWeekIsAtIndex = getCurrentWeekNumber()-1
        let currentWeekIndexPath = IndexPath(row: currentWeekIsAtIndex, section: 0)
        tableView.scrollToRow(at: currentWeekIndexPath, at: .middle, animated: true)
    }

    
    func swipeRightHandler(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentDetailedView(forWeek selectedWeek: Int){
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let detailedView: WeeksDetailedTableViewController = storyBoard.instantiateViewController(withIdentifier: "WeeksDetailedTableViewControllerID") as! WeeksDetailedTableViewController
    
        detailedView.weekNumber = selectedWeek
        self.present(detailedView, animated: false, completion: nil)
        
    }
    
    // Pass data to WeeksDetailedTableViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "WeeksTableToDetailed") {
            let destination = segue.destination as! WeeksDetailedTableViewController
            destination.weekNumber = currentlySelectedWeek
        }
    }

    // MARK: - Table View Setup

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentDetailedView(forWeek: indexPath.row+1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        currentlySelectedWeek = indexPath.row + 1
        
        let cellIdentifier = "WeekTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WeekTableViewCell

        cell.weekNumberLabel!.text = String(weekArray[indexPath.row])
        
        if cell.weekNumberLabel!.text == String(getCurrentWeekNumber()){
  
            cell.currentWeekLabel.isHidden = false
        } else {cell.currentWeekLabel.isHidden = true}
        
        // Gesture Recognizers - left
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightRecognizer.direction = .right
        swipeRightRecognizer.cancelsTouchesInView = true // false lets touches pass thorough to other recognizers so that it is not blocked
        cell.addGestureRecognizer(swipeRightRecognizer)
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
