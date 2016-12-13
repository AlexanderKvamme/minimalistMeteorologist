//
//  TodayViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/12/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import Charts

class TodayViewController: UIViewController, ChartViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var stack1Image: UIImageView!
    @IBOutlet weak var stack1Label: UILabel!
    @IBOutlet weak var stack2Image: UIImageView!
    @IBOutlet weak var stack2Label: UILabel!
    @IBOutlet weak var stack3Image: UIImageView!
    @IBOutlet weak var stack3Label: UILabel!
    
    let combinedLineColor = UIColor.black
    var temperatures : [Double] = [-1,1,1,2,4,2,1,2,1,-1]
    var shortenedTimestamps = [Double]()
    var timestamps: [Double] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        getChartData()
        setUI()
        setChartLayout()
        setChartData()
        addSwipeRecognizers()
        
        //displayDay(1)
        /*
        for day in latestExtendedWeatherFetched!.dailyWeather!{
            print(day.time)
            print(day.dayName)
        }
        */
        
        //print("avslutningsvis temp array: ", temperatures)

    }
    
    func displayDay(_ number: Int){
        
        let number = 3
        
       
        
        if let day = latestExtendedWeatherFetched?.dailyWeather?[number]{
            
            
            
        
            // PSEUDO
            print("-- displayData --")
        
            self.dayLabel.text = day.dayName
            self.dateLabel.text = "bam"
//            print("number inn: ", number)
//            print("gir date: ", day.date)
//            print("gir dayName: ", day.dayName)
//            print("gir dayNumber: ", day.dayNumber)
            
        }
        
        
        
        
        /*
         if let currentWeather = latestExtendedWeatherFetched?.currentWeather{
         print(currentWeather)
         
         dayLabel.text = getCurrentDayName().uppercased()
         dateLabel.text = getCurrentDate()
         
         weatherIcon.image = UIImage(named: currentWeather.WeatherIcon.rawValue)
         
         summaryLabel.text = currentWeather.summary
         
         // set temperature, wind and precipitation
         stack1Label.text = currentWeather.windSpeedInPreferredUnit.description
         stack1Image.image = UIImage(named: "weathercock.png")
         
         stack2Label.text = String(currentWeather.precipProbabilityPercentage) + "%"
         stack2Image.image = UIImage(named: currentWeather.precipIcon.rawValue + ".png")
         
         stack3Image.image = UIImage(named: "temperature.png")
         stack3Label.text = currentWeather.temperatureInPreferredUnit.description
         }*/
    }
    
    func animateBack(){
        
        print("Tryna animate back")
    }
    
    func addSwipeRecognizers(){
        
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer()
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        
        //swipe down
        
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownHandler))
        swipeDownGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    func swipeDownHandler(){
        print("swipeDownHandler")
        self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
    }
    
    func swipeRightHandler(){
        print("swipeRightHandler")
        //self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
    }
    
    func setUI(){
    
        if let currentWeather = latestExtendedWeatherFetched?.currentWeather{
            print(currentWeather)
        
            dayLabel.text = currentWeather.dayName.uppercased()
            dateLabel.text = currentWeather.date
            
            weatherIcon.image = UIImage(named: currentWeather.WeatherIcon.rawValue)
            
            summaryLabel.text = currentWeather.summary
            
            // set temperature, wind and precipitation
            stack1Label.text = currentWeather.windSpeedInPreferredUnit.description
            stack1Image.image = UIImage(named: "weathercock.png")
            
            stack2Label.text = String(currentWeather.precipProbabilityPercentage) + "%"
            stack2Image.image = UIImage(named: currentWeather.precipIcon.rawValue + ".png")
            
            stack3Image.image = UIImage(named: "temperature.png")
            stack3Label.text = currentWeather.temperatureInPreferredUnit.description
        }
    }
    
    
    
    
    func getChartData(){
        
        if let extendedData = latestExtendedWeatherFetched{
            
            if let hourlyData = extendedData.hourlyWeather{
                
                var temperatureArray: [Double] = []
                var timestampArray: [Double] = []
                var shortenedTimestampArray: [Double] = []
                
                for day in hourlyData{
                    
                    temperatureArray.append(day.temperature)
                    timestampArray.append(day.time)
                    shortenedTimestampArray.append(shortenTimestamp(day.time))
                    if shortenTimestamp(day.time) == 0{
                        break // End of day reached
                    }
                }
                
                temperatures = temperatureArray
                timestamps = timestampArray
                shortenedTimestamps = shortenedTimestampArray
            
            }
        } else {
            // send new extendedDataRequest or wait for the previous one to finish
        }
    }
    
    func setChartLayout(){
        
        
        // frame
        
        lineChartView.layer.borderColor = UIColor.black.cgColor
        lineChartView.layer.borderWidth = 0
        lineChartView.isUserInteractionEnabled = false
        
        // chart
        
        self.lineChartView.delegate = self
        //self.lineChartView.chartDescription?.text = "Temperature in Celcius"
        self.lineChartView.chartDescription?.text = ""
        self.lineChartView.drawGridBackgroundEnabled = false
        self.lineChartView.drawBordersEnabled = false
        self.lineChartView.noDataText = "Not enough data provided"
        self.lineChartView.legend.enabled = false
        
        // - leftAxis
        
        self.lineChartView.leftAxis.zeroLineColor = combinedLineColor
        self.lineChartView.leftAxis.drawZeroLineEnabled = true
        self.lineChartView.leftAxis.axisLineWidth = 0
        self.lineChartView.leftAxis.drawLabelsEnabled = false
        self.lineChartView.leftAxis.drawAxisLineEnabled = false
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        self.lineChartView.leftAxis.granularityEnabled = true
        self.lineChartView.leftAxis.granularity = 2
        
        // - rightAxis
        
        self.lineChartView.rightAxis.drawLabelsEnabled = false
        self.lineChartView.rightAxis.drawAxisLineEnabled = false
        self.lineChartView.rightAxis.drawGridLinesEnabled = false
        
        // - xAxis
        
        self.lineChartView.xAxis.axisLineColor = .yellow
        self.lineChartView.xAxis.drawGridLinesEnabled = true // vertical lines
        self.lineChartView.xAxis.drawLabelsEnabled = true
        self.lineChartView.xAxis.drawAxisLineEnabled = false
        self.lineChartView.xAxis.labelPosition = .bottom

        //test
 
        print(" -- TEST --")
        //print(self.lineChartView.xAxis.axisMinimum)
        //print(shortenedTimestamps)
        
        // Denne neste linjnen bugger seg av og til
        self.lineChartView.xAxis.axisMinimum = shortenedTimestamps[0]
        self.lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        self.lineChartView.xAxis.granularity = 2

        // test end
    }
    
    
    func setChartData() {
        
        for timestamp in timestamps{
            shortenedTimestamps.append(shortenTimestamp(timestamp))
        }
        
        // 1 - Creating an array of data entries
        
        var valuesToGraph: [ChartDataEntry] = [ChartDataEntry]()
        
        //for i in 0 ..< temperatures.count {
        for i in 0 ... (temperatures.count-1) {
            //valuesToGraph.append(ChartDataEntry(x: Double(timestamps[i]), y: temperatures[i]))
            valuesToGraph.append(ChartDataEntry(x: shortenedTimestamps[i], y: temperatures[i]))
        }
        
        // Custom Formatter
        
        let hourBasedFormatter = HourBasedLineChartFormatter()
        let xAxis = XAxis()
        xAxis.valueFormatter = hourBasedFormatter
        //lineChartView.xAxis.valueFormatter = xAxis.valueFormatter
        lineChartView.xAxis.valueFormatter = hourBasedFormatter
        
        for i in 0 ... (timestamps.count-1){
            shortenedTimestamps.append(shortenTimestamp(timestamps[i]))
        }

        // 2 - Create data set
        
        let set1: LineChartDataSet = LineChartDataSet(values: valuesToGraph, label: nil)
        set1.axisDependency = .left
        set1.setColor(combinedLineColor)
        set1.setCircleColor(combinedLineColor)
        set1.lineWidth = 2.0
        set1.circleRadius = 4.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = combinedLineColor
        set1.highlightColor = .white
        set1.highlightEnabled = false
        set1.drawCircleHoleEnabled = true
        set1.circleHoleRadius = 2.0
        
        // set Y-values to 0 decimal points
        
        let format = NumberFormatter()
        format.generatesDecimalNumbers = false
        let formatter = DefaultValueFormatter(formatter:format)
        lineChartView.lineData?.setValueFormatter(formatter)
        set1.valueFormatter = formatter
        
        // 3 - Create an array to store our LineChartDataSets
        
        var dataSets = [LineChartDataSet]()
        dataSets.append(set1)
        //print("\ndataSets: \n", dataSets)
        
        // 4 - pass our months in for our x-axis label value along with our dataSets
        
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(.black)
        
        // 5 - set our data
        
        self.lineChartView.data = data
        
    }
    
    // Prepare timestamps for formatter
    
    
    
    func shortenTimestamp(_ value: Double) -> Double {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        let date: Date = Date(timeIntervalSince1970: value)
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let newNumber: Double = Double(hour) * 100 + Double(minute)
        
        //print("value: ", value)
        //print("newNumber: ", newNumber)
        //print()
        
        return newNumber
    }
}

