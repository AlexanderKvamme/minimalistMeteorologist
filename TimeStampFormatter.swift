

import Foundation

class TimeStampFormatter: NSObject, IAxisValueFormatter{
    // Used by Charts to get HH:MM format along the x-axis
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var timeString = String(Int(value))
        switch timeString.length{
        case 3:
            timeString = "0" + timeString
        case 1:
            timeString = "0000"
        default: break
        }
        var HHMM = timeString
        HHMM.insert(":", at: timeString.index(HHMM.startIndex, offsetBy: 2))
        return HHMM
    }
}

