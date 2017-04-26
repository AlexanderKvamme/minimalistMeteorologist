

import UIKit
import Charts

class TodayViewController: UIViewController, ChartViewDelegate, UIGestureRecognizerDelegate{
    
    // MARK: - Outlets
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherIconHeightConstraint: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var spaceOverDayName: UIView!
    
    @IBOutlet weak var spaceOverDayNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var spaceUnderDayName: UIView!
    @IBOutlet weak var spaceUnderDayNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tripleStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceOverTemperatureHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var spaceOverGraph: UIView!
    
    @IBOutlet weak var spaceUnderGraphHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var imageStack = [UIImageView]()
    var viewStack = [UIView]()
    
    let combinedLineColor = UIColor.black //Dots and lines for the graph
    var temperatures : [Double] = []
    var dayIndex: Int = 0
    let maxSummaryLines = 3
    
    enum AnimationDirection{
        case left
        case right
    }
    
    enum DeviceSize{
        case Smallest
        case Small
        case Big
        case Biggest
        
        init(deviceHeight: CGFloat){
            switch deviceHeight{
            case 480: // iphone 3 and 4
                self = .Smallest
                
            case 568: // iphone 5
                self = .Small
                
            case 667: // iphone 6 without display zoom
                self = .Big

            default:
                self = .Biggest
                
            }
        }
    }
    
    var superAnimation: UIViewPropertyAnimator!
    var headerLabelPositionLeft: CGFloat!
    var headerLabelPositionRight: CGFloat!
    var animationDirection: AnimationDirection!
    var headerXShift: CGFloat = 10 // animation x-distance
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if DeviceSize(deviceHeight: view.frame.size.height) == .Small {
            resizeUIElements()
        }
        
        imageStack = [self.stack1Image, self.stack2Image, self.stack3Image]
        viewStack = [self.dayLabel, self.dateLabel, self.weatherIcon, self.summaryLabel, self.stack2Image, self.iconStack, self.stack1Label, self.stack2Label, self.stack3Label]
        
        setUI()
        setChartLayout()
        displayDay(at: dayIndex)
        addSwipeAndPanRecognizers()
    }
    
    // FIXME: - Resize elements for smaller iphones
    
    func resizeUIElements(){
        self.spaceOverDayName.translatesAutoresizingMaskIntoConstraints = false
        self.spaceOverDayNameHeightConstraint.constant = 0
        self.spaceUnderDayNameHeightConstraint.constant = 5
        self.weatherIconHeightConstraint.constant = 100
        self.tripleStackHeightConstraint.constant = 20
        self.spaceOverTemperatureHeightConstraint.constant = 5
        self.spaceUnderGraphHeightConstraint.constant = 5
    }
    
    // MARK: - UI Setup
    
    func setUI(){
        stackHeader.alpha = 0.3
        graphHeader.alpha = 0.3
        stack3Image.image = UIImage(named: "weathercock.png")
        stack1Image.image = UIImage(named: "temperature.png")
    }
    
    func updateUIWith(newDay day: DayData){
        let temperatureLabel = stack1Label!
        let windLabel = stack3Label!
        let precipitationLabel = stack2Label!
        let precipitationImage = stack2Image!
        dayLabel.text = day.dayName.uppercased()
        dayLabel.sizeToFit()
        dateLabel.text = day.formattedDate
        weatherIcon.image = UIImage(named: day.weatherIcon.rawValue)
        summaryLabel.text = day.summary
        setLabel(label: summaryLabel, summary: day.summary)
        windLabel.text = "\(Int(round(day.windSpeedInPreferredUnit.value))) \(day.windSpeedInPreferredUnit.unit.symbol)"
        precipitationLabel.text = "\(day.precipProbability.asIntegerPercentage)%"
        precipitationImage.image = UIImage(named: day.precipIcon.rawValue)
        guard let averageTemperature = day.averageTemperatureInPreferredUnit else {
            temperatureLabel.text = "Missing data"
            return
        }
        stack1Label.text = String(Int(round(averageTemperature.value))) + " " + averageTemperature.unit.symbol
    }

    // MARK: - Animation Methods
    
    // MARK: - Main Animation
    
    func moveViewsWithPan(gesture: UIPanGestureRecognizer){
        
        // if swiped down
        if (gesture.translation(in: view).y > 50 && abs(gesture.translation(in: view).x) < 50) && gesture.state == .ended{
            swipeDownHandler()
        }
        // if pan just started
        if gesture.state == .began {
            if gesture.velocity(in: view).x > 0{
                animationDirection = .left
            } else {
                animationDirection = .right
            }
            prepareAnimation(forDirection: animationDirection)
        }
        
        // if mid pan
        superAnimation.fractionComplete = abs(gesture.translation(in: self.view).x/100)
        
        // if pan ended
        if gesture.state == .ended{
            if abs(gesture.translation(in: self.view).x) > 100{
                switch animationDirection!{
                case .left:
                    displayDay(at: dayIndex-1)
                case .right:
                    displayDay(at: dayIndex+1)
                }
            }
            animateBackToOriginalLayout(fromCurrentGesture: gesture)
        }
    }
    
    func animateBackToOriginalLayout(fromCurrentGesture gesture: UIPanGestureRecognizer){
        dayLabel.textAlignment = .center
        superAnimation.isReversed = true
        let v = gesture.velocity(in: view)
        let velocity = CGVector(dx: v.x / 200, dy: v.y / 200)
        let timingParameters = UISpringTimingParameters(mass: 200, stiffness: 50, damping: 100, initialVelocity: velocity)
        superAnimation.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0.2)
    }
    
    func slideUI(direction: AnimationDirection){
        let labelStack: [UILabel] = [self.stack1Label!, self.stack2Label!, self.stack3Label!]
        if direction == .left{
            slideComponents(.left)
            slideLabels(labelStack, direction: .left, additionalSlide: 5)
        }
        if direction == .right {
            slideComponents(.right)
            slideLabels(labelStack, direction: .right, additionalSlide: 5)
        }
    }
    
    func slideComponents(_ direction: AnimationDirection){
        let iconRotationAmount: CGFloat = 0.05
        let summaryRotation = -CGFloat.pi * 0.005
        switch direction{
        case .left:
            self.dayLabel.center = CGPoint(x: self.dayLabel.center.x - 20, y: self.dayLabel.center.y)
            self.dateLabel.center = CGPoint(x: self.dateLabel.center.x + 20, y: self.dateLabel.center.y)
            self.summaryLabel.transform = CGAffineTransform(translationX: 40, y: -8).rotated(by: summaryRotation)
            self.iconStack.transform = CGAffineTransform(translationX: 10, y: 0)
            self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: 0.50, y: 0.50)
            self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: 0.75, y: 0.75).translatedBy(x: 100, y: 0)
        case .right:
            self.dayLabel.center = CGPoint(x: self.dayLabel.center.x + 20, y: self.dayLabel.center.y)
            self.dateLabel.center = CGPoint(x: self.dateLabel.center.x - 20, y: self.dateLabel.center.y)
            self.summaryLabel.transform = CGAffineTransform(translationX: -40, y: -8).rotated(by: -summaryRotation)
            self.iconStack.transform = CGAffineTransform(translationX: -10, y: 0)
            self.stack2Image.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: 0.50, y: 0.50)
            self.weatherIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: 0.75, y: 0.75).translatedBy(x: -100, y: 0)
        }
    }
    
    func slideLabels(_ labels: [UILabel], direction: AnimationDirection, additionalSlide: CGFloat){
        switch direction{
        case .right:
            dayLabel.textAlignment = .right
            for label in labels{
                let frame = label.frame
                label.frame = CGRect(x: frame.minX - additionalSlide, y: frame.minY, width: frame.width, height: frame.height)
            }
        case .left:
            dayLabel.textAlignment = .left
            for label in labels{
                let frame = label.frame
                label.frame = CGRect(x: frame.minX + additionalSlide, y: frame.minY, width: frame.width, height: frame.height)
            }
        }
    }
    
    func twistImages(_ images: [UIImageView], direction: AnimationDirection){
        let iconRotationAmount: CGFloat = 0.05
        let sideStackImageDownscaleAmount: CGFloat = 0.9
        let precipitationIconDownscaleAmount: CGFloat = 0.50
        switch direction{
        case .right:
            images[0].transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
            images[1].transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
            images[2].transform = CGAffineTransform(rotationAngle: CGFloat.pi * iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
        case .left:
            images[0].transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
            images[1].transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: precipitationIconDownscaleAmount, y: precipitationIconDownscaleAmount)
            images[2].transform = CGAffineTransform(rotationAngle: CGFloat.pi * -iconRotationAmount).scaledBy(x: sideStackImageDownscaleAmount, y: sideStackImageDownscaleAmount)
        }
    }
    
    func prepareAnimation(forDirection direction: AnimationDirection){
        self.superAnimation = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            if direction == .left{
                self.slideUI(direction: .left)
                self.twistImages(self.imageStack, direction: .left)
            }
            if direction == .right {
                self.slideUI(direction: .right)
                self.twistImages(self.imageStack, direction: .right)
            }
           self.fadeLabels()
        }
    }
    
    func fadeLabels(){
        self.dateLabel.alpha = 0
        self.summaryLabel.alpha = 0
        self.stack1Label.alpha = 0
        self.stack2Label.alpha = 0
        self.stack3Label.alpha = 0
    }
    
    // MARK: - Swipe And Pan Recognizers And Handlers
    
    func addSwipeAndPanRecognizers(){
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer()
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownHandler))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.moveViewsWithPan)))
    }
    
    func swipeDownHandler(){
        performSegue(withIdentifier: "unwindToMainMenu", sender: self)
    }
    
    // MARK: - Data Methods
    
    func displayDay(at requestedIndex: Int){
        var daysWithHourData = 0
        for day in latestExtendedWeatherFetch.dailyWeather!{
            if day.hourData != nil {
                daysWithHourData += 1
            }
        }

        if requestedIndex < 0  || requestedIndex >= daysWithHourData{
         print("Not enough hourData to graph this day")
            return
        }
        
        guard let requestedDay = latestExtendedWeatherFetch.dailyWeather?[requestedIndex] else {
            return
        }
        
        updateChart(withDay: requestedIndex)
        updateUIWith(newDay: requestedDay)
        dayIndex = requestedIndex
    }
    
    // MARK: - Charts Methods
    
    func getChartData(forDay requestedDay: Int) -> [ChartDataEntry]? {
        
        var temperatures: [Double] = []
        var valuePairs: [ChartDataEntry] = [ChartDataEntry]()
        //print("printer requestedDay:\n")
        //print(latestExtendedWeatherFetch?.dailyWeather?[requestedDay])
        guard let hours = latestExtendedWeatherFetch.dailyWeather?[requestedDay].hourData else {
            //FIXME: - Here
            print("problem with getting chart data for day: ",requestedDay)
            print("does not contain hourData")
            return nil
        }
        for hour in hours{
            if round(hour.temperature) == -0.0 {
                temperatures.append(0)
            } else {
                temperatures.append(hour.temperature)
            }
            if shortenTimestamp(hour.time) == 0 { // Prevent including temperatures past midnight
                break
            }
        }
        for i in 0 ..< temperatures.count {
            valuePairs.append(ChartDataEntry(x: shortenTimestamp(hours[i].time), y: temperatures[i]))
        }
        return valuePairs
    }
    
    func setChartData(withDataEntries dataEntries: [ChartDataEntry]) {
        let xAxis = XAxis()
        xAxis.valueFormatter = TimeStampFormatter()
        lineChartView.xAxis.valueFormatter = TimeStampFormatter()
        
        let set1: LineChartDataSet = LineChartDataSet(values: dataEntries, label: nil)
        set1.axisDependency = .left
        set1.setColor(combinedLineColor)
        set1.setCircleColor(combinedLineColor)
        set1.lineWidth = 2.0
        set1.circleRadius = 4.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = combinedLineColor
        set1.highlightEnabled = false
        set1.drawCircleHoleEnabled = true
        set1.circleHoleRadius = 2.0
        
        // FIXME: - send inn set2
        
        let format = NumberFormatter()
        format.generatesDecimalNumbers = true
        let formatter = DefaultValueFormatter(formatter:format)
        lineChartView.lineData?.setValueFormatter(formatter)
        set1.valueFormatter = formatter
        
        var dataSets = [LineChartDataSet]()
        dataSets.append(set1)
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(.black)
        self.lineChartView.data = data
        
        adjustChartLayout(forDataEntries: dataEntries)
    }
    
    func setChartLayout(){
        lineChartView.layer.borderColor = UIColor.black.cgColor
        lineChartView.layer.borderWidth = 0
        lineChartView.isUserInteractionEnabled = false
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
        lineChartView.xAxis.granularity = 2
        lineChartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 10)
        //self.lineChartView.chartDescription?.text = "Temperatures this day in INSERT UNIT TYPE"
    }

    func adjustChartLayout(forDataEntries dataset: [ChartDataEntry]){
        lineChartView.xAxis.axisMinimum = dataset[0].x
        let titleFont = UIFont(name: "Poly-Regular", size: 16)!
        lineChartView.noDataFont = titleFont
        lineChartView.contentMode = .center
        if dataset.count == 1 {
            if let preferredUnit = latestExtendedWeatherFetch.dailyWeather?[0].averageTemperatureInPreferredUnit?.unit.symbol {
                lineChartView.noDataText = "Current temperature is \(Int(round(dataset[0].y)))\(preferredUnit)"
            }
            lineChartView.clear()
        }
        if dataset.count < 5 {
            lineChartView.animate(xAxisDuration: 0.1, yAxisDuration: 0.0)
        } else {
            lineChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.0)
        }
    }
    
    func updateChart(withDay day: Int){
        
        if let newDataEntries = getChartData(forDay: day){
            setChartData(withDataEntries: newDataEntries)
        }
    }
    
    // MARK: - Helper Methods

    // Typography methods
    
    func setLabel(label: UILabel, summary: String){
        label.text = "Placeholder to establish lineheight"
        label.numberOfLines = 1
        label.sizeToFitHeight()
        label.text = summary
        while label.willBeTruncated(){
            label.numberOfLines += 1
            label.text = balanceTextAlignment(summary, overLines: summaryLabel.numberOfLines)
            label.sizeToFitHeight()
        }
        if label.numberOfLines > maxSummaryLines{
            label.text = summary // no balance needed
        }
    }
    
    func balanceTextAlignment(_ text: String, overLines: Int) -> String {
        // used to balance the text over X amount of lines, without creating typographic orphans.
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

