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
    
    // MARK: Properties
    
    var weekNumber: Int?
    var dailyWeatherArray = [DailyWeather] ()
    var fetchedDays = 0
    let desiredAmountOfDays = 3

    @IBOutlet weak var weekHeaderLabel: UILabel!
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Swipe recognizer
        
        addSwipeRecognizer()
        // nib
        
        let nib = UINib(nibName: "DayTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DayTableViewCell")
        
        updateHeader()
        
        setUserDefaultsIfInitialRun()
        let coordinate = Coordinate(lat: 59.9, lon: 10.75)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
 
        let selectedWeek = weekNumber ?? 99
        
        let datesToFetch: [Date] = getFullWeekOfTimestamps(week: selectedWeek)
        
        for days in 0...(desiredAmountOfDays-1){
            let request = makeTimeMachineRequest(forDay: datesToFetch[days], atCoordinate: coordinate)
            fetchDayFromRequestToIndex(request: request, session: session)
        }
    }//viewDidLoad
    
    //Mark: Functions
    
    func addSwipeRecognizer(){
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer()
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightGestureRecognizer.direction = .right
        tableView.addGestureRecognizer(swipeRightGestureRecognizer)

    }
    
    func swipeRightHandler(){
        self.performSegue(withIdentifier: "unwindToWeeks", sender: self)
    }
    
    func fetchDayFromRequestToIndex(request: URLRequest, session: URLSession){
        let dataTask = session.dataTask(with: request, completionHandler: { data, error, response in
            
            if let data = data{
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : AnyObject]
                    
                    print(json)
                    
                    let dailyJSON = json["daily"] as! [String : AnyObject]
                    
                    if let daily = dailyJSON["data"] as? [[String : AnyObject]]{
                        
                        for days in daily{
                            if let newDay = DailyWeather(JSONDay: days){
                                
                                self.dailyWeatherArray.append(newDay)
                                self.fetchedDays += 1
                                
                                if self.fetchedDays == self.desiredAmountOfDays {
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
            if data == nil {
                print("data var nil")
            }
        })
        dataTask.resume()
    }

    func updateUI(){
        dailyWeatherArray = sortDailyWeatherArray(dailyWeatherArray)
        tableView.reloadData()
    }
    
    func sortDailyWeatherArray(_ array: [DailyWeather]) -> [DailyWeather]{
        
        let sortedArray = array.sorted(by: { (day1, day2) -> Bool in
            return day1.time < day2.time
        })
        
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

    // MARK: - TableView datasource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dailyWeatherArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayTableViewCell", for: indexPath) as! DayTableViewCell
        
        let day = dailyWeatherArray[indexPath.row]

        cell.temperatureLabel.text = String(Int(round(day.averageTemperatureInPreferredUnit.value))) + day.averageTemperatureInPreferredUnit.unit.symbol
        
        cell.percentageLabel.text = String(day.precipProbabilityPercentage) + "%"
        
        var daysOfTheWeek = "MTWTFSS"
        let dayLetter = [Character](daysOfTheWeek.characters)
        cell.firstLetterOfDayLabel.text = String(dayLetter[indexPath.row])
        cell.windSpeedValueLabel.text = String(Int(round(day.windSpeedInPreferredUnit.value)))
        cell.windSpeedUnitLabel.text = String(day.windSpeedInPreferredUnit.unit.symbol)
        cell.weatherIconImageView.image = UIImage(named: day.weatherIcon.rawValue)
        cell.precipitationIconImageView.image = UIImage(named: day.precipIcon.rawValue)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
//    func getUNIXArrayFromWeek(number weekNumber: Int) -> [Int] {
//        
//            let calendar = Calendar.current
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .long
//            var components = DateComponents()
//        
//            components.yearForWeekOfYear = 2016
//            components.weekOfYear = weekNumber
//        
//            let dateFromComponents = calendar.date(from: components)
//    
//            let returnDates = [Int]()
//            
//            // bruk denne til å lagre array av denne og de 6 følgende datoene som unix
//            
//            if let dateFromComponents = dateFromComponents{
//                
//                for dayIndex in 0...3 {
//                    let temp = calendar.date(byAdding: .day, value: dayIndex, to: dateFromComponents)
//                }
//                return returnDates
//            }
//            return returnDates
//        }
    
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
        
        return dateFromComponents?.timeIntervalSince1970
        
    }
}
