//
//  WeeksDetailedTableViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 14/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

protocol WeeksTableViewDelegate {
    func setWeek(_ weekNumber: Int)
}

class WeeksDetailedTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var weekNumber: Int?
    var dailyWeatherArray = [DailyWeather]()
    var fetchedDays = 0
    
    @IBOutlet weak var weekHeaderLabel: UILabel!
    @IBAction func didSwipeRight(_ sender: Any) {
        print("user didSwipeRight")
    }
    @IBOutlet var swipeRightRecognizer: UISwipeGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateHeader()
        
        let coordinate = Coordinate(lat: 59.9, lon: 10.75)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
 
        let selectedWeek = weekNumber ?? 99
        
        // MAY HAVE TO return Int64
        let datesToFetch: [Date] = getFullWeekOfTimestamps(week: selectedWeek)
        
        for days in 0...2{
            let request = makeTimeMachineRequest(forDay: datesToFetch[days], atCoordinate: coordinate)
            fetchDayFromRequestToIndex(request: request, session: session)
        }
    }//viewDidLoad
    
    func fetchDayFromRequestToIndex(request: URLRequest, session: URLSession){
        let dataTask = session.dataTask(with: request, completionHandler: { data, error, response in
            
            print("tryna fetch by req: ", request)
            if let data = data{
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : AnyObject]
                    
                    //print(json)
                    
                    let dailyJSON = json["daily"] as! [String : AnyObject]
                    
                    if let daily = dailyJSON["data"] as? [[String : AnyObject]]{
                        
                        for days in daily{
                            if let newDay = DailyWeather(JSONDay: days){
                                
                                self.dailyWeatherArray.append(newDay)
                                self.fetchedDays += 1
                                print("FETCHED DAYS:", self.fetchedDays)
                                
                                if self.fetchedDays == 3 {
                                    DispatchQueue.main.async(execute: {
                                        self.updateUI()
                                    })
                                }
                            }}
                    }
                } catch{
                    print("Error: ", error.localizedDescription)
                }
            }
            if error != nil {
                //print("Fant en error: '\(error)'")
                print("Error detected")
            }
            if data == nil {
                print("data var nil")
            }
        })
        dataTask.resume()
    }

    func updateUI(){
   
        dailyWeatherArray = sortDailyWeatherArray(dailyWeatherArray)
        print("KAN NÅ BEGYNNE Å PLOTTE INN I TABELLEN")
        
        
    }
    
    func sortDailyWeatherArray(_ array: [DailyWeather]) -> [DailyWeather]{
        
        let sortedArray = array.sorted(by: { (day1, day2) -> Bool in
            return day1.time < day2.time
        })
        
        print("sorted array to:")
        for index in 0...(sortedArray.count - 1 ) {
            print(Date.init(timeIntervalSince1970: array[index].time))
        }
        return sortedArray
    }
    
    func getFullWeekOfTimestamps(week: Int) -> [Date]{
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        var components = DateComponents()
        
        components.yearForWeekOfYear = 2016
        components.weekOfYear = week
        components.hour = 12 // Mid day to avoid timezone changes
        
        let firstDayOfWeek = calendar.date(from: components)
        var datesOfRequestedWeek = [Date]()
        
        for days in 0...6{
            
            let newDay = calendar.date(byAdding: .day, value: days, to: firstDayOfWeek!)!
            print("Date made for array: " + dateFormatter.string(from: newDay))
            datesOfRequestedWeek.append(newDay)
        }
        
        return datesOfRequestedWeek
    }
    
    func updateHeader(){
        if let weekNumber = weekNumber{
            weekHeaderLabel.text = "WEEK " + String(weekNumber)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    
    
    func getUNIXArrayFromWeek(number weekNumber: Int) -> [Int] {
            
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            var components = DateComponents()
            
            print("mottar uke:", weekNumber)
            components.yearForWeekOfYear = 2016
            components.weekOfYear = weekNumber
        
            let dateFromComponents = calendar.date(from: components)
            print("startingdate: ", dateFromComponents!)
            print("I unix: ", dateFromComponents?.timeIntervalSince1970)
    
            var returnDates = [Int]()
            
            // bruk denne til å lagre array av denne og de 6 følgende datoene som unix
            
            if let dateFromComponents = dateFromComponents{
                
                let unixDate = dateFromComponents.timeIntervalSince1970
                
                for dayIndex in 0...6 {
                    let temp = calendar.date(byAdding: .day, value: dayIndex, to: dateFromComponents)
                    
                    if let temp = temp{
                        print(Int(temp.timeIntervalSince1970))
                     
                    }
                    
                    //returnDates[dayIndex] = Int(calendar.date(byAdding: .day, value: dayIndex, to: unixDate))
                    
                    //let tempDate2 = calendar.date(byAdding: .day, value: 2, to: tempDate)
                    //print("unixresultat: ", )
                    
                }
            
                return returnDates
            }
            
            return returnDates
            
        }
    
    func getDayInUNIXFormat(fromDay day: Int, week: Int) -> Int? {
        
        print("mottat: dag \(day), and week \(week)")
        print("getSpecificDayDate mottar ønske om dato fra day: \(day), week: \(week)")
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        var components = DateComponents()
        
        components.yearForWeekOfYear = calendar.component(.year, from: Date())
        components.day = day
        
        let dateFromComponents = calendar.date(from: components)
        
        if let dateFromComponents = dateFromComponents{
            print("Date made from components in getDayInUNIXFormat: " + dateFormatter.string(from: dateFromComponents))
            print(" - Returning: ", Int(dateFromComponents.timeIntervalSince1970))
            return Int(dateFromComponents.timeIntervalSince1970)
        }
        
        return nil
        
    }

    func makeTimeMachineRequest(forDay date: Date, atCoordinate coordinate: Coordinate) -> URLRequest{
        
        let baseURLString = "https://api.forecast.io/forecast/\(forecastAPIKey)/"
        let currentPreferredUnits = UserDefaults.standard.string(forKey: "preferredUnits")!
        
        let timeStamp = Int64(date.timeIntervalSince1970)
        
        let pathString = "\(coordinate.latitude),\(coordinate.longitude),\((timeStamp))?units=\(currentPreferredUnits.lowercased())&exclude=hourly,currently,flag"
        
        let endpointString = baseURLString + pathString
        let endpoint = URL(string: endpointString, relativeTo: nil)!
        
        return URLRequest(url: endpoint, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 0)
    }
    
    func getFirstDayOfWeekAsUNIX(number weekNumber: Int) -> TimeInterval? {
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        var components = DateComponents()
        
        components.yearForWeekOfYear = 2016
        components.weekOfYear = 6
        
        let dateFromComponents = calendar.date(from: components)
        
        if let dateFromComponents = dateFromComponents{
            print("Date made from components:" + dateFormatter.string(from: dateFromComponents))
        }
        
        /* // if you wanna return as a string
         
         let UNIXTimestamp = dateFromComponents?.timeIntervalSince1970
         if let UNIXTimestamp = UNIXTimestamp{
         let temp = String(UNIXTimestamp)
         
         return temp
         
         }
         */
        
        return dateFromComponents?.timeIntervalSince1970
        
    }
   
    func sortDatesChronologically(dates: [Date]){
        
        let copiedDates = dates
        copiedDates.sorted()
        print(dates)
        print()
        //dates.sortInPlace({ $0.compare($1) == ComparisonResult.OrderedAscending })
        print(dates)
    }
}
