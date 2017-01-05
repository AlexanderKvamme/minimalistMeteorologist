//
//  TodayViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/12/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import Charts

enum AnimationDirection{
    
    case left
    case right
}

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
    @IBOutlet weak var iconStack: UIStackView!
    
    let combinedLineColor = UIColor.black
    var temperatures : [Double] = [-1,1,1,2,4,2,1,2,1,-1]
    var shortenedTimestamps = [Double]()
    var timestamps: [Double] = []
    var dayIndex: Int = 0
    
    // animation properties
    
    var myAnimation: UIViewPropertyAnimator!
    var animateToXPos: CGPoint!
    var headerLabelPositionLeft: CGFloat!
    var headerLabelPositionRight: CGFloat!
    var headerLabelpositionX: CGFloat!
    var headerLabelPositionY: CGFloat!
    var animationDirection: AnimationDirection!
    
    var headerXShift: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // swipe animation
        headerLabelPositionLeft = dayLabel.frame.midX + headerXShift
        headerLabelPositionRight = dayLabel.frame.midX - headerXShift
        headerLabelPositionY = dayLabel.frame.midY
        headerLabelpositionX = dayLabel.frame.midX
        
        dayLabel.textAlignment = .center
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.move))
        view.addGestureRecognizer(pan)

        //content setup
        
        getChartData()
        setChartLayout()
        setChartData()
        setUI()
        addSwipeRecognizers()
    }
    
    func move(gesture: UIPanGestureRecognizer){
        
        if (gesture.translation(in: view).y > 50 && abs(gesture.translation(in: view).x) < 50) {
            self.swipeDownHandler()
        }
        
        if gesture.state == .began {
            
            if gesture.velocity(in: view).x > 0{
                
                // Panning right, Animate Left
                self.animationDirection = .left
                self.animateToXPos = CGPoint(x: headerLabelPositionLeft!, y: headerLabelPositionY!)
                self.setAnimation(direction: AnimationDirection.left)
                self.dayLabel.textAlignment = .left
                
            } else {
                
                // Panning left, Animate Right
                self.animationDirection = AnimationDirection.right
                self.animateToXPos = CGPoint(x: self.view.bounds.width - (self.dayLabel.frame.size.width/2), y: headerLabelPositionY)
                self.setAnimation(direction: AnimationDirection.right)
                self.dayLabel.textAlignment = .right
            }
        }
        
        self.myAnimation.fractionComplete = abs(gesture.translation(in: self.view).x/100)
        //print(abs(gesture.translation(in: self.view).x/100))
        
        if gesture.state == .ended{
            
            // if swiped far left/right - update data
            
            self.dayLabel.textAlignment = .center
            
            if abs(gesture.translation(in: self.view).x) > 100{ // if hard swipe right
                
                // go to next/prev data
                
                if animationDirection == .left {

                        displayPreviousDay()
                    }

                
                if animationDirection == .right {
        
                        displayNextDay()
                }
             
                dayLabel.sizeToFit()
            }
            
            self.myAnimation.isReversed = true
            let v = gesture.velocity(in: view)
            let velocity = CGVector(dx: v.x / 200, dy: v.y / 200)
            let timingParameters = UISpringTimingParameters(mass: 200, stiffness: 50, damping: 100, initialVelocity: velocity)
            
            self.myAnimation.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0.2)
        } // if .ended
    }
    
    
    func setAnimation(direction: AnimationDirection){
        self.myAnimation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            
            let dayLabelPos = self.dayLabel.center.y
            let dateLabelYPos = self.dateLabel.center.y
            let dateLabelXShift: CGFloat = 20
            let iconRotationAmount: CGFloat = 0.05
            let iconDownscaleAmount: CGFloat = 0.75
            let iconTranslationAmount: CGFloat = 100
            
            let summaryYShift: CGFloat = -8
            let summaryXShift: CGFloat = 40
            let summaryRotation = -CGFloat.pi * 0.005
            
            let iconStackXShift: CGFloat = 10
            let iconStackYShift: CGFloat = 0
            
            let precipitationIconDownscaleAmount: CGFloat = 0.50
            let sideStackImageDownscaleAmount: CGFloat = 0.9
            let stackLabelOffset: CGFloat = 5
            
            if direction == AnimationDirection.left{
                //user swipes right
                self.dayLabel.center = CGPoint(x: self.headerLabelPositionLeft, y: dayLabelPos)
                self.dateLabel.center = CGPoint(x: self.headerLabelPositionLeft + dateLabelXShift, y: dateLabelYPos)
                self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: iconDownscaleAmount, y: iconDownscaleAmount).translatedBy(x: iconTranslationAmount, y: 0)
                
                self.summaryLabel.transform = CGAffineTransform(translationX: summaryXShift, y: summaryYShift).rotated(by: summaryRotation)
               
                self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
       
                // move labels right
                
                self.iconStack.transform = CGAffineTransform(translationX: iconStackXShift, y: iconStackYShift)
                
                for label in [self.stack1Label, self.stack2Label, self.stack3Label]{
                    let frame = label!.frame
                    label!.frame = CGRect(x: frame.minX + stackLabelOffset, y: frame.minY, width: frame.width, height: frame.height)
                }
                
                // twist images
                
                for image in [self.stack1Image, self.stack2Image, self.stack3Image]{
                    //var frame = image!.frame
                    if image == self.stack2Image {
                 
                        image!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
                    } else {
                        
                        image!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
                        
                    }
                }
                
            } else {
                //user swipes left
                self.dayLabel.center = CGPoint(x: self.headerLabelPositionRight, y: dayLabelPos)
                self.dateLabel.center = CGPoint(x: self.headerLabelPositionRight - dateLabelXShift, y: dateLabelYPos)
                
                self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: iconDownscaleAmount, y: iconDownscaleAmount).translatedBy(x: -iconTranslationAmount, y: 0)
                
                self.summaryLabel.transform = CGAffineTransform(translationX: -summaryXShift, y: summaryYShift).rotated(by: -summaryRotation)
                
                
                self.iconStack.transform = CGAffineTransform(translationX: -iconStackXShift, y: iconStackYShift)
                self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
                
                // twist images
                for image in [self.stack1Image, self.stack2Image, self.stack3Image]{
                    //var frame = image!.frame
                    if image == self.stack2Image {
                        
                        image!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
                    } else {
                        
                        image!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
                        
                    }
                }
                
                // move labels left
                for label in [self.stack1Label, self.stack2Label, self.stack3Label]{
                    let frame = label!.frame
                    label!.frame = CGRect(x: frame.minX - stackLabelOffset, y: frame.minY, width: frame.width, height: frame.height)
                }
                
                
            }
            
            self.dateLabel.alpha = 0
            self.summaryLabel.alpha = 0
            self.stack1Label.alpha = 0
            self.stack2Label.alpha = 0
            self.stack3Label.alpha = 0
        }
    }
    
    // data configuration methods
    
    func getChartDataForSelectedDay(){
        
            if let hourlyData = latestExtendedWeatherFetched?.dailyWeather?[dayIndex].hourData{
                
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
                
        } else {
            // send new extendedDataRequest or wait for the previous one to finish
        }
    }

    
    
    
    
    
    
    
    
    func displayNextDay(){
    
        if dayIndex == (latestExtendedWeatherFetched!.dailyWeather!.count - 2){
            
            // Using 2 to not display last day of the fetch which is often without accurate data
            print("index out of range")}
        else {
            
            if let day = latestExtendedWeatherFetched?.dailyWeather?[dayIndex+1]{
            
                dayIndex += 1
                getChartDataForSelectedDay()
                setChartData()
                setChartLayout()
                
                self.dayLabel.text = day.dayName.uppercased()
                self.dateLabel.text = day.formattedDate
                self.weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
                self.summaryLabel.text = day.summary
                self.stack1Label.text = day.windSpeedInPreferredUnit.description
                self.stack2Label.text = (day.precipProbabilityPercentage?.description)! + "%"
                self.stack2Image.image = UIImage(named: (day.precipIcon?.rawValue)!)
                self.stack3Label.text = day.averageTemperatureInPreferredUnit.description
            
            }
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        self.viewDidLoad()
    }
    
    func displayPreviousDay(){
        
        if dayIndex == 0{
            
            // already at first day
        
        } else{
            
            if let day = latestExtendedWeatherFetched?.dailyWeather?[dayIndex-1]{
            
                dayIndex -= 1
                
                getChartDataForSelectedDay()
                setChartData()
                setChartLayout()
            
                self.dayLabel.text = day.dayName.uppercased()
                self.dateLabel.text = day.formattedDate
                self.weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
                self.summaryLabel.text = day.summary
                self.stack1Label.text = day.windSpeedInPreferredUnit.description
                self.stack2Label.text = (day.precipProbabilityPercentage?.description)! + "%"
                self.stack2Image.image = UIImage(named: (day.precipIcon?.rawValue)!)
                self.stack3Label.text = day.averageTemperatureInPreferredUnit.description
            }
        }
    }
    
    func addSwipeRecognizers(){
        
        // swipe right
        
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer()
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeRightGestureRecognizer)
        
        // swipe left
        
        var swipeLeftGestureRecognizer = UISwipeGestureRecognizer()
        swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftHandler))
        swipeLeftGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)

        
        // swipe down
        
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownHandler))
        swipeDownGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    func swipeDownHandler(){

        self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
    }
    
    func swipeRightHandler(){ displayPreviousDay() }
    
    func swipeLeftHandler(){ displayNextDay() }
    
    func setUI(){
        
        if let currentWeather = latestExtendedWeatherFetched?.currentWeather{
            //print("currentWeahter: ", currentWeather)
            print("latestEXTENDEDCurrentWeather temp: ", latestExtendedWeatherFetched?.currentWeather?.temperature as Double!)
        
            dayLabel.text = currentWeather.dayName.uppercased()
            dayLabel.sizeToFit()
            dateLabel.text = currentWeather.date
            dateLabel.sizeToFit()
            
            weatherIcon.image = UIImage(named: currentWeather.WeatherIcon.rawValue)
            
            // summary label
            summaryLabel.text = currentWeather.summary
            summaryLabel.text =
            summaryLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            summaryLabel.sizeToFit()
            summaryLabel.text = summaryLabel.text?.uppercased()
            
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
        
        // animation
        
        //lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.0)
        
        // chart
        
        self.lineChartView.delegate = self
        //self.lineChartView.chartDescription?.text = "Temperatures this day in Celcius"
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

 
        //print(self.lineChartView.xAxis.axisMinimum)
        
        // Denne neste linjnen bugger seg av og til
        self.lineChartView.xAxis.axisMinimum = shortenedTimestamps[0]
        self.lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        self.lineChartView.xAxis.granularity = 2
        
        // Padding
        self.lineChartView.extraBottomOffset = 8
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

