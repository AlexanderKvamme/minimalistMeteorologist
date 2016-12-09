//
//  ViewController.swift
//  ChartsTestPod
//
//  Created by Alexander Kvamme on 28/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit
import Charts

class ViewControllerz: UIViewController, ChartViewDelegate{
    
    let combinedLineColor = UIColor.black
    
    var temperatures : [Double] = [-1,1,1,2,4,2,1,2,1,-1]
    var timestamps: [Double] = [ 1481115600, 1481119200, 1481122800, 1481126400, 1481130000, 1481133600, 1481137200,1481140800, 1481144400, 1481148000]
    var shortenedTimestamps = [Double]()
    
    // 1481115600
    // becomes
    // 1481120000.0
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for timestamp in timestamps{
            shortenedTimestamps.append(shortenTimestamp(timestamp))
        }
        
        // frame
        
        lineChartView.layer.borderColor = UIColor.black.cgColor
        lineChartView.layer.borderWidth = 0
        
        // chart
        
        self.lineChartView.delegate = self
        self.lineChartView.chartDescription?.text = "Temperature in Celcius"
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
        self.lineChartView.leftAxis.granularity = 4
        
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
        
        setChartData()
    }
    
    func setChartData() {
        
        // 1 - Creating an array of data entries
        
        var valuesToGraph: [ChartDataEntry] = [ChartDataEntry]()
        
        //for i in 0 ..< temperatures.count {
        for i in 0 ... (temperatures.count-1) {
            print("loop i: ", i)
            print("loop temperature: ", temperatures[i])
            print("loop timestamp[i]: ", timestamps[i])
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
        print("shortened timestamps:")
        print(shortenedTimestamps)
        
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
        
        
        // set y values to show 0 decimal points
        let format = NumberFormatter()
        format.generatesDecimalNumbers = false
        let formatter = DefaultValueFormatter(formatter:format)
        lineChartView.lineData?.setValueFormatter(formatter)
        set1.valueFormatter = formatter
        
        // 3 - Create an array to store our LineChartDataSets
        
        var dataSets = [LineChartDataSet]()
        dataSets.append(set1)
        print("dataSets: ", dataSets)
        
        // 4 - pass our months in for our x-axis label value along with our dataSets
        
        let data: LineChartData = LineChartData(dataSets: dataSets)
        data.setValueTextColor(.black)
        print("data: ", data)
        
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
        
        print("received in shortener: ", value)
        print("AKA:", formatter.string(from: date))
        print("Shortened to: ", newNumber)
        
        return newNumber
    }
}
