

import Foundation
import UIKit

extension Double{
    var asPercentage: Double {
        return self * 100
    }
    var asIntegerPercentage: Int {
        return Int(self * 100)
    }
}

extension UILabel {
    func sizeToFitHeight() {
        let size:CGSize = self.sizeThatFits(CGSize(width: self.frame.size.width, height: .greatestFiniteMagnitude))
        var frame:CGRect = self.frame
        frame.size.height = size.height
        self.frame = frame
    }
}

// makes a new UILabel with infinite height and infinite number of lines and sees if the height of the resulting UILabel is higher than the UILabel in question. If so, the UILabel in question has been truncated

extension UILabel {
    func willBeTruncated() -> Bool {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        if label.frame.height > self.frame.height {
            return true
        }
        return false
    }
}

extension UILabel{
    func requiredHeight() -> CGFloat{
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}

