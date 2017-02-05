

import Foundation

// MARK: - Extensions

extension DayData{
    var formattedDate: String {
        let date = Date(timeIntervalSince1970: self.time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    var date: Date {
        return Date.init(timeIntervalSince1970: self.time)
    }
}

// MARK: - Extensions with default implementations

// MARK: HasDayName

protocol HasDayName{
    var dayName: String { get }
    var time: Double { get }
}

extension HasDayName{
    var dayName: String{
        let date = Date(timeIntervalSince1970: self.time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.string(from: date)
        return dayOfWeekString
    }
}

// MARK: HasDayNumber

protocol HasDayNumber{
    var dayNumber: Int { get }
    var time: Double { get }
}

extension HasDayNumber{
    var dayNumber: Int{
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: self.time)
        let components = calendar.dateComponents([.day,.month,.year], from: date)
        return components.day!
    }
}

// MARK: hasAverageTemperatureInPreferredUnit

protocol hasAverageTemperatureInPreferredUnits {
    var hourData: [HourData]? { get set}
}

extension hasAverageTemperatureInPreferredUnits{
    var averageTemperatureInPreferredUnit: Measurement<Unit>? {
        guard let hourData = hourData else {return nil}
        let averageTemperature = averageTemperatureFromHours(hourData)
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        
        switch preferredUnitSystem{
        case "US":
            if round(averageTemperature) == -0 {
                return Measurement(value: 0, unit: UnitTemperature.fahrenheit)
            }
            return Measurement(value: round(averageTemperature), unit: UnitTemperature.fahrenheit)
        default:
            if round(averageTemperature) == -0 {
                return Measurement(value: 0, unit: UnitTemperature.celsius)
            }
            return Measurement(value: round(averageTemperature), unit: UnitTemperature.celsius)
        }
    }
}

// MARK: hasWindSpeedInPreferredUnit

protocol hasWindSpeedInPreferredUnit{
    var windSpeed: Double { get set }
    var windSpeedInPreferredUnit: Measurement<Unit> { get }
}

extension hasWindSpeedInPreferredUnit{
    var windSpeedInPreferredUnit: Measurement<Unit> {
        let preferredUnitSystem = UserDefaults.standard.string(forKey: "preferredUnits") ?? "SI"
        switch preferredUnitSystem{
        case "CA":
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.kilometersPerHour)
        case "UK2", "US":
            return Measurement(value: round(self.windSpeed), unit: UnitSpeed.milesPerHour)
        default: return Measurement(value: round(self.windSpeed), unit: UnitSpeed.metersPerSecond)
        }
    }
}

// MARK: - Helper Methods

func averageTemperatureFromHours(_ hours: [HourData]) -> Double{
    var sum: Double = 0
    for hour in hours{
        sum += hour.temperature
    }
    return sum/Double(hours.count)
}

func dailyArrayFromJSON(_ dailyData: [[String : AnyObject]]) -> [DayData]{
    var arrayOfDayData: [DayData] = []
    for day in dailyData{
        let myDayData = DayData(JSONDay: day)
        if let myDayData = myDayData{
            arrayOfDayData.append(myDayData)
        }
    }
    return arrayOfDayData
}

func hourlyArrayFromJSON(_ hourlyData: [[String : AnyObject]]) -> [HourData]{
    var arrayOfHourData: [HourData] = []
    for hour in hourlyData{
        let myHourData = HourData(hourDictionary: hour)
        if let myHourData = myHourData{
            arrayOfHourData.append(myHourData)
        }
    }
    return arrayOfHourData
}

