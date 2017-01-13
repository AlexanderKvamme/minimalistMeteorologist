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
    @IBOutlet weak var stackHeader: UILabel!
    @IBOutlet weak var stack1Image: UIImageView!
    @IBOutlet weak var stack1Label: UILabel!
    @IBOutlet weak var stack2Image: UIImageView!
    @IBOutlet weak var stack2Label: UILabel!
    @IBOutlet weak var stack3Image: UIImageView!
    @IBOutlet weak var stack3Label: UILabel!
    @IBOutlet weak var iconStack: UIStackView!
    @IBOutlet weak var graphHeader: UILabel!
    
    let combinedLineColor = UIColor.black // Graph dots and lines
    var temperatures : [Double] = []
    var shortenedTimestamps = [Double]()
    var timestamps: [Double] = []
    var dayIndex: Int = 0
    
    let maxSummaryLines = 3 //
    
    // animation properties
    
    var myAnimation: UIViewPropertyAnimator!
    var animateToXPos: CGPoint!
    var headerLabelPositionLeft: CGFloat!
    var headerLabelPositionRight: CGFloat!
    var headerLabelpositionX: CGFloat!
    var headerLabelPositionY: CGFloat!
    var animationDirection: AnimationDirection!
    
    var headerXShift: CGFloat = 10 // animation x length
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // swipe animation translation endpoints
        headerLabelPositionLeft = dayLabel.frame.midX + headerXShift
        headerLabelPositionRight = dayLabel.frame.midX - headerXShift
        headerLabelPositionY = dayLabel.frame.midY
        headerLabelpositionX = dayLabel.frame.midX
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.move))
        view.addGestureRecognizer(pan)

        //content setup
        getChartDataForIndexedDay()
        setChartLayout()
        setChartData()
        setUI()
        displayFirstDay()
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
        
        if gesture.state == .ended{
            
            // if long swipe, update labels with next/previous day
            
            self.dayLabel.textAlignment = .center
            
            if abs(gesture.translation(in: self.view).x) > 100{
                
                // go to next/prev data
                
                if animationDirection == .left { displayPreviousDay() }
                if animationDirection == .right { displayNextDay() }
             
                dayLabel.sizeToFit()
            }
            
            // animate UI back to original position
            self.myAnimation.isReversed = true
            let v = gesture.velocity(in: view)
            let velocity = CGVector(dx: v.x / 200, dy: v.y / 200)
            let timingParameters = UISpringTimingParameters(mass: 200, stiffness: 50, damping: 100, initialVelocity: velocity)
            
            self.myAnimation.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0.2)
        }
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
            
            // Set animation direction
            
            if direction == AnimationDirection.left{
                
                // user swipes left
                
                self.dayLabel.center = CGPoint(x: self.headerLabelPositionLeft, y: dayLabelPos)
                self.dateLabel.center = CGPoint(x: self.headerLabelPositionLeft + dateLabelXShift, y: dateLabelYPos)
                self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: iconDownscaleAmount, y: iconDownscaleAmount).translatedBy(x: iconTranslationAmount, y: 0)
                
                self.summaryLabel.transform = CGAffineTransform(translationX: summaryXShift, y: summaryYShift).rotated(by: summaryRotation)
               
                self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
       
                // move labels
                
                self.iconStack.transform = CGAffineTransform(translationX: iconStackXShift, y: iconStackYShift)
                
                for label in [self.stack1Label, self.stack2Label, self.stack3Label]{
                    let frame = label!.frame
                    label!.frame = CGRect(x: frame.minX + stackLabelOffset, y: frame.minY, width: frame.width, height: frame.height)
                }
                
                // twist images
                
                for image in [self.stack1Image, self.stack2Image, self.stack3Image]{

                    if image == self.stack2Image {
                 
                        image!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
                    } else {
                        
                        image!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
                        
                    }
                }
                
            } else {
                
                // user swipes left
                
                self.dayLabel.center = CGPoint(x: self.headerLabelPositionRight, y: dayLabelPos)
                self.dateLabel.center = CGPoint(x: self.headerLabelPositionRight - dateLabelXShift, y: dateLabelYPos)
                
                self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: iconDownscaleAmount, y: iconDownscaleAmount).translatedBy(x: -iconTranslationAmount, y: 0)
                
                self.summaryLabel.transform = CGAffineTransform(translationX: -summaryXShift, y: summaryYShift).rotated(by: -summaryRotation)
                
                
                self.iconStack.transform = CGAffineTransform(translationX: -iconStackXShift, y: iconStackYShift)
                self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
                
                // twist images
                for image in [self.stack1Image, self.stack2Image, self.stack3Image]{
                    
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
    
    func getChartDataForIndexedDay(){
        
            if let hourlyData = latestExtendedWeatherFetched?.dailyWeather?[dayIndex].hourData{
                
                //print("TODO:hourlyData: \n", hourlyData)
                var temperatureArray: [Double] = []
                var timestampArray: [Double] = []
                var shortenedTimestampArray: [Double] = []
                
                for day in hourlyData{
                    
                    if day.temperature >= -0.5 && day.temperature <= 0{
                        temperatureArray.append(0)
                    } else{
                        temperatureArray.append(day.temperature)
                    }
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
            print("index out of range")
        } else {
            
            if let day = latestExtendedWeatherFetched?.dailyWeather?[dayIndex+1]{
            
                dayIndex += 1
                getChartDataForIndexedDay()
                setChartData()
                setChartLayout()
                
                self.dayLabel.text = day.dayName.uppercased()
                self.dateLabel.text = day.formattedDate
                self.weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
                
                setLabel(label: self.summaryLabel, summary: day.summary)
                
                self.stack3Label.text = String(Int(round(day.windSpeedInPreferredUnit.value)))  + " " + day.windSpeedInPreferredUnit.unit.symbol
                self.stack2Label.text = (day.precipProbabilityPercentage?.description)! + "%"
                self.stack2Image.image = UIImage(named: (day.precipIcon?.rawValue)!)
                self.stack1Label.text = String(Int(round(day.averageTemperatureInPreferredUnit.value))) + " " + day.averageTemperatureInPreferredUnit.unit.symbol
            }
        }
    }
    
    func setLabel(label: UILabel, summary: String){
        
        //
        
        label.text = "establish lineheight"
        label.numberOfLines = 1
        label.sizeToFitHeight()
        label.text = summary
        
        while label.willBeTruncated(){
            label.numberOfLines += 1
            label.text = balanceText(summary, overLines: summaryLabel.numberOfLines)
            label.sizeToFitHeight()
        }

        if label.numberOfLines > maxSummaryLines{
            print("too many lines.")
            label.text = summary // no balance needed
        }
    }
    
    func balanceText(_ text: String, overLines: Int) -> String {
        
        print()
        print("- start -")
        print()
        
        var i = [Int]()
        var x = [Int]()
        var chars = Array(text.characters)
        
        print("char count: ", chars.count)
        for index in 0..<overLines-1{
            // 56 / 2 skal bli 28 men blir 18?
            i.append(chars.count/overLines * (index+1))
            x.append(chars.count/overLines * (index+1))
        }
        print("array har valgt splitpunkter: ", i)
        
        for index in (0..<i.count).reversed(){
            
            while chars[i[index]] != " " && chars[x[index]] != " " {
                
                i[index] -= 1
                x[index] += 1
            }
            
            if chars[i[index]] == " " {
                
                chars.insert("\n", at: i[index]+1)
            } else {
                chars.insert("\n", at: x[index]+1)
            }
            
            print()
            print("after this split string is now: \n", String(chars))
            print("--- ")
            print()
        }
        
        return String(chars)
    }
    
    func newSplittedString(text input: String, targetLabel: UILabel) -> String {
        
        var i = [Int]()
        var x = [Int]()
        //var text = input.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range:nil)
        var text = input
        var chars = Array(text.characters)
        print("mottar initial:", input)
        print("mottar uten newLines", text)
        print()
        print("while loop start")
        print("---")
        
        //targetLabel.numberOfLines = 1
        print("will b truncated? ", targetLabel.willBeTruncated())
        // Start splitting if willBeTruncated - begynner med 2 linjer, men truncated, så vi legger til en tredje linje
        while targetLabel.willBeTruncated(){
            
            targetLabel.numberOfLines += 1 // Må splittes. øker med en linjer
            print("will b truncated: ", targetLabel.willBeTruncated())
            print("så legger til en linje og vi har nå ant linjer: ", targetLabel.numberOfLines)
            text = input // starter med ren tekst igjen
            
            for index in 0..<targetLabel.numberOfLines-1{
                
                // generate search starting point for each
                
                i.append(chars.count/targetLabel.numberOfLines * (index+1))
                x.append(chars.count/targetLabel.numberOfLines * (index+1))
            }
            
            print("array har valgt splitpunkter: ", i)
            
            // move pointers
            print("chars før greien: ", String(chars))
            for index in (0..<i.count).reversed(){
                
                while chars[i[index]] != " " && chars[x[index]] != " " {
                    i[index] -= 1
                    x[index] += 1
                }
                
                if chars[i[index]] == " " {
                    chars.insert("\n", at: i[index]+1)
                } else {
                    chars.insert("\n", at: x[index]+1)
                }
                print("string so far: \n", String(chars))
                print(" --------- ")
            }
            
            print("number of lines is now: ", targetLabel.numberOfLines)
            print("returning:\n", String(chars))
            return String(chars)
        }
        print("didnt have to split lines. returning original text")
        return input
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        self.viewDidLoad()
    }
    
    func displayFirstDay(){
        if let day = latestExtendedWeatherFetched?.dailyWeather?[0]{
            
            dayIndex = 0
            
            getChartDataForIndexedDay()
            setChartData()
            setChartLayout()
            
            self.dayLabel.text = day.dayName.uppercased()
            self.dateLabel.text = day.formattedDate
            self.weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
            
            setLabel(label: self.summaryLabel, summary: day.summary)
            
            self.stack3Label.text = String(Int(round(day.windSpeedInPreferredUnit.value))) + " " + day.windSpeedInPreferredUnit.unit.symbol
            self.stack2Label.text = (day.precipProbabilityPercentage?.description)! + "%"
            self.stack2Image.image = UIImage(named: (day.precipIcon?.rawValue)!)
            self.stack1Label.text = String(Int(round(day.averageTemperatureInPreferredUnit.value))) + " " + day.averageTemperatureInPreferredUnit.unit.symbol
            
        }
    }
    
    func displayPreviousDay(){
        
        if dayIndex == 0{
            
            // already at first day. Do nothing
        
        } else{
            
            if let day = latestExtendedWeatherFetched?.dailyWeather?[dayIndex-1]{
            
                dayIndex -= 1
                
                getChartDataForIndexedDay()
                setChartData()
                setChartLayout()
            
                self.dayLabel.text = day.dayName.uppercased()
                self.dateLabel.text = day.formattedDate
                self.weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
                self.summaryLabel.text = day.summary
                setLabel(label: self.summaryLabel, summary: day.summary)
                
                self.stack3Label.text = String(Int(round(day.windSpeedInPreferredUnit.value))) + " " + day.windSpeedInPreferredUnit.unit.symbol
                self.stack2Label.text = (day.precipProbabilityPercentage?.description)! + "%"
                self.stack2Image.image = UIImage(named: (day.precipIcon?.rawValue)!)
                self.stack1Label.text = String(Int(round(day.averageTemperatureInPreferredUnit.value))) + " " + day.averageTemperatureInPreferredUnit.unit.symbol
    
    
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
        
        stackHeader.alpha = 0.3
        graphHeader.alpha = 0.3
        
        stack3Image.image = UIImage(named: "weathercock.png")
        stack1Image.image = UIImage(named: "temperature.png")
    }
    
    func setChartLayout(){
        
        // frame
        
        lineChartView.layer.borderColor = UIColor.black.cgColor
        lineChartView.layer.borderWidth = 0
        lineChartView.isUserInteractionEnabled = false
        
        // animation
        
        lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.0)
        
        // chart
        
        self.lineChartView.delegate = self
        //self.lineChartView.chartDescription?.text = "Temperatures this day in INSERT UNIT TYPE"
        self.lineChartView.chartDescription?.text = ""
        self.lineChartView.drawGridBackgroundEnabled = false
        self.lineChartView.drawBordersEnabled = false
        self.lineChartView.noDataText = "Not enough data provided"
        self.lineChartView.legend.enabled = false
        
        // - leftAxis
        
        self.lineChartView.leftAxis.zeroLineColor = combinedLineColor
        //self.lineChartView.leftAxis.drawZeroLineEnabled = true
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

        
        // TASK: - TODO: Denne neste linjnen bugger seg av og til
        self.lineChartView.xAxis.axisMinimum = shortenedTimestamps[0]
        //self.lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        self.lineChartView.xAxis.granularity = 2
        
        // Padding
        self.lineChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 10)
    }
    
    
    func setChartData() {
        
        for timestamp in timestamps{
            shortenedTimestamps.append(shortenTimestamp(timestamp))
        }
        
        // 1 - Creating an array of data entries
        
        var valuesToGraph: [ChartDataEntry] = [ChartDataEntry]()
    
        
        for i in 0 ..< temperatures.count {
            valuesToGraph.append(ChartDataEntry(x: shortenedTimestamps[i], y: temperatures[i]))
        }
        
        // Custom Formatter
        
        let hourBasedFormatter = HourBasedLineChartFormatter()
        let xAxis = XAxis()
        xAxis.valueFormatter = hourBasedFormatter
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
        
        if temperatures.count == 1 {
            print(" few temps. Check out ")
            print("datasets:")
            print(dataSets)
        }
        
        // 4 - pass our months in for our x-axis label value along with our dataSets
        
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(.black)
        
        // 5 - set our data
        
        self.lineChartView.data = data
    }
    
    func shortenTimestamp(_ value: Double) -> Double {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        let date: Date = Date(timeIntervalSince1970: value)
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let newNumber: Double = Double(hour) * 100 + Double(minute)
        
        return newNumber
    }
}
