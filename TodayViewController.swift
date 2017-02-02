//
//  TodayViewController.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/12/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import Charts

// FIXME: Gjør om til egen metode og send inn left or right for å unngå duplicate

class TodayViewController: UIViewController, ChartViewDelegate, UIGestureRecognizerDelegate{
    
    // MARK: - Outlets
    
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
    
    // MARK: - Properties
    
    let combinedLineColor = UIColor.black //Dots and lines for the graph
    var temperatures : [Double] = []
    var shortenedTimestamps = [Double]()
    var timestamps: [Double] = []
    var dayIndex: Int = 0
    let maxSummaryLines = 3
    
    enum AnimationDirection{
        case left
        case right
    }
    
    var swipeAnimation: UIViewPropertyAnimator!
    var animateToXPos: CGPoint!
    var headerLabelPositionLeft: CGFloat!
    var headerLabelPositionRight: CGFloat!
    var headerLabelpositionX: CGFloat!
    var headerLabelPositionY: CGFloat!
    var animationDirection: AnimationDirection!
    var headerXShift: CGFloat = 10 // animation x-distance
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set label animation destinations
        headerLabelPositionLeft = dayLabel.frame.midX + headerXShift
        headerLabelPositionRight = dayLabel.frame.midX - headerXShift
        headerLabelPositionY = dayLabel.frame.midY
        headerLabelpositionX = dayLabel.frame.midX

        // setup
        getChartDataForIndexedDay()
        setChartLayout()
        setChartData()
        setUI()
        displayFirstDay()
        addSwipeRecognizers()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.move)))
    }
    
    // MARK: Motion Began
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        viewDidLoad()
    }
    
    // MARK: - Animation Methods
    
    func move(gesture: UIPanGestureRecognizer){
        
        if (gesture.translation(in: view).y > 50 && abs(gesture.translation(in: view).x) < 50) && gesture.state == .ended{ swipeDownHandler() }
        
        if gesture.state == .began {
            if gesture.velocity(in: view).x > 0{
                
                // Animate Left
                animationDirection = .left
                animateToXPos = CGPoint(x: headerLabelPositionLeft!, y: headerLabelPositionY!)
                setAnimation(direction: AnimationDirection.left)
                dayLabel.textAlignment = .left
                
            } else {
                
                // Animate Right
                animationDirection = AnimationDirection.right
                animateToXPos = CGPoint(x: view.bounds.width - (dayLabel.frame.size.width/2), y: headerLabelPositionY)
                setAnimation(direction: AnimationDirection.right)
                dayLabel.textAlignment = .right
            }
        }
        
        swipeAnimation.fractionComplete = abs(gesture.translation(in: self.view).x/100)
        
        if gesture.state == .ended{
            dayLabel.textAlignment = .center
            if abs(gesture.translation(in: self.view).x) > 100{
                
                switch animationDirection!{
                case .left:
                    displayPreviousDay()
                case .right:
                    displayNextDay()
                }
                dayLabel.sizeToFit()
            }
            
            // animate UI back to original position
            swipeAnimation.isReversed = true
            let v = gesture.velocity(in: view)
            let velocity = CGVector(dx: v.x / 200, dy: v.y / 200)
            let timingParameters = UISpringTimingParameters(mass: 200, stiffness: 50, damping: 100, initialVelocity: velocity)
            swipeAnimation.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0.2)
        }
    }
    
    func setAnimation(direction: AnimationDirection){
        
        self.swipeAnimation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            
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
                
                self.dayLabel.center = CGPoint(x: self.headerLabelPositionLeft, y: dayLabelPos)
                self.dateLabel.center = CGPoint(x: self.headerLabelPositionLeft + dateLabelXShift, y: dateLabelYPos)
                self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: iconDownscaleAmount, y: iconDownscaleAmount).translatedBy(x: iconTranslationAmount, y: 0)
                self.summaryLabel.transform = CGAffineTransform(translationX: summaryXShift, y: summaryYShift).rotated(by: summaryRotation)
                self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
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
    
    // MARK: - Swipe Recognizers And Handlers
    
    func addSwipeRecognizers(){
        
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer()
        swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightHandler))
        swipeRightGestureRecognizer.direction = .right
        view.addGestureRecognizer(swipeRightGestureRecognizer)
        
        var swipeLeftGestureRecognizer = UISwipeGestureRecognizer()
        swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftHandler))
        swipeLeftGestureRecognizer.direction = .left
        view.addGestureRecognizer(swipeLeftGestureRecognizer)
    
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownHandler))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
    }
    
    func swipeDownHandler(){ performSegue(withIdentifier: "unwindToMainMenu", sender: self) }
    
    func swipeRightHandler(){ displayPreviousDay() }
    
    func swipeLeftHandler(){ displayNextDay() }
    
    // MARK: - UI Setup
    
    func setUI(){
        
        stackHeader.alpha = 0.3
        graphHeader.alpha = 0.3
        stack3Image.image = UIImage(named: "weathercock.png")
        stack1Image.image = UIImage(named: "temperature.png")
    }
    
    func setChartLayout(){
        
        lineChartView.layer.borderColor = UIColor.black.cgColor
        lineChartView.layer.borderWidth = 0
        lineChartView.isUserInteractionEnabled = false
        lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.0)
        lineChartView.delegate = self
        lineChartView.chartDescription?.text = ""
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.drawBordersEnabled = false
        lineChartView.noDataText = "Not enough data provided"
        lineChartView.legend.enabled = false
        lineChartView.leftAxis.zeroLineColor = combinedLineColor
        lineChartView.leftAxis.axisLineWidth = 0
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.granularityEnabled = true
        lineChartView.leftAxis.granularity = 2
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.axisLineColor = .yellow
        lineChartView.xAxis.drawGridLinesEnabled = true // vertical lines
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.axisMinimum = shortenedTimestamps[0]
        lineChartView.xAxis.granularity = 2
        lineChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 10)
        //self.lineChartView.chartDescription?.text = "Temperatures this day in INSERT UNIT TYPE"
    }
    
    func setChartData() {
        
        for timestamp in timestamps{
            shortenedTimestamps.append(shortenTimestamp(timestamp))
        }
        
        var valuesToGraph: [ChartDataEntry] = [ChartDataEntry]()
    
        
        for i in 0 ..< temperatures.count {
            valuesToGraph.append(ChartDataEntry(x: shortenedTimestamps[i], y: temperatures[i]))
        }
        
        let hourBasedFormatter = TimeStampFormatter()
        let xAxis = XAxis()
        xAxis.valueFormatter = hourBasedFormatter
        lineChartView.xAxis.valueFormatter = hourBasedFormatter
        
        for i in 0 ... (timestamps.count-1){
            shortenedTimestamps.append(shortenTimestamp(timestamps[i]))
        }
        
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
        
        let format = NumberFormatter()
        format.generatesDecimalNumbers = false
        let formatter = DefaultValueFormatter(formatter:format)
        lineChartView.lineData?.setValueFormatter(formatter)
        set1.valueFormatter = formatter
        
        var dataSets = [LineChartDataSet]()
        dataSets.append(set1)
        
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(.black)
        
        self.lineChartView.data = data
    }
    
    func displayFirstDay(){
        if let day = latestExtendedWeatherFetch?.dailyWeather?[0]{
            dayIndex = 0
            getChartDataForIndexedDay()
            setChartData()
            setChartLayout()
            dayLabel.text = day.dayName.uppercased()
            dateLabel.text = day.formattedDate
            weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
            setLabel(label: summaryLabel, summary: day.summary)
            stack3Label.text = String(Int(round(day.windSpeedInPreferredUnit.value))) + " " + day.windSpeedInPreferredUnit.unit.symbol
            let chanceOfRain = day.precipProbability.asIntegerPercentage
            stack2Label.text = "\(chanceOfRain)%"
          
            let iconName = day.precipIcon.rawValue
            stack2Image.image = UIImage(named: iconName)
            guard let averageTemperature = day.averageTemperatureInPreferredUnit else {
                stack1Label.text = "Missing data"
                return
            }
            stack1Label.text = String(Int(round(averageTemperature.value))) + " " + averageTemperature.unit.symbol
        }
    }
    
    func getChartDataForIndexedDay(){
        
        if let hourlyData = latestExtendedWeatherFetch?.dailyWeather?[dayIndex].hourData{
            
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
        
        if dayIndex == (latestExtendedWeatherFetch!.dailyWeather!.count - 2){ // Using 2 to avoid last days often inaccurate data
        } else {
            if let day = latestExtendedWeatherFetch?.dailyWeather?[dayIndex+1]{
                dayIndex += 1
                getChartDataForIndexedDay()
                setChartData()
                setChartLayout()
                
                dayLabel.text = day.dayName.uppercased()
                dateLabel.text = day.formattedDate
                weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
                setLabel(label: summaryLabel, summary: day.summary)
                stack3Label.text = String(Int(round(day.windSpeedInPreferredUnit.value)))  + " " + day.windSpeedInPreferredUnit.unit.symbol
                
                let chanceOfRain = day.precipProbability.asIntegerPercentage
                    stack2Label.text = "\(chanceOfRain)%"
             
                let iconName = day.precipIcon.rawValue
                    stack2Image.image = UIImage(named: iconName)
                
                guard let averageTemperature = day.averageTemperatureInPreferredUnit else {
                    stack1Label.text = "Missing data"
                    return
                }
                stack1Label.text = String(Int(round(averageTemperature.value))) + " " + averageTemperature.unit.symbol
            }
        }
    }
    
    func displayPreviousDay(){
        
        if dayIndex == 0{
            // already at first day. Do nothing
        } else{
            
            if let day = latestExtendedWeatherFetch?.dailyWeather?[dayIndex-1]{
                
                dayIndex -= 1
                getChartDataForIndexedDay()
                setChartData()
                setChartLayout()
                
                dayLabel.text = day.dayName.uppercased()
                dateLabel.text = day.formattedDate
                weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
                summaryLabel.text = day.summary
                setLabel(label: summaryLabel, summary: day.summary)
                
                stack3Label.text = String(Int(round(day.windSpeedInPreferredUnit.value))) + " " + day.windSpeedInPreferredUnit.unit.symbol

                let chanceOfRain = day.precipProbability.asIntegerPercentage
                    stack2Label.text = "\(chanceOfRain)%"
           
                let iconName = day.precipIcon.rawValue
                    stack2Image.image = UIImage(named: iconName)
                
                guard let averageTemperature = day.averageTemperatureInPreferredUnit else {
                    stack1Label.text = "Missing data"
                    return
                }
                stack1Label.text = String(Int(round(averageTemperature.value))) + " " + averageTemperature.unit.symbol
            }
        }
    }
    
    
    // MARK: - Data configuration methods
    
    
    func setLabel(label: UILabel, summary: String){
        
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
            label.text = summary // no balance needed
        }
    }
    
    func balanceText(_ text: String, overLines: Int) -> String {
        
        var i = [Int]()
        var x = [Int]()
        var chars = Array(text.characters)
        
        for index in 0..<overLines-1{
            i.append(chars.count/overLines * (index+1))
            x.append(chars.count/overLines * (index+1))
        }
        
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
        }
        return String(chars)
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
