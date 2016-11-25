//
//  UITableView+autoSnapping.swift
//  AutoSnapping
//
//  Created by Nobuo Saito on 2015/08/20.
//  Copyright © 2015 tarunon. All rights reserved.
//

import Foundation
import UIKit

//private let roundingHeight: CGFloat = 100.0
private let roundingHeight: CGFloat = UIScreen.main.bounds.height

public extension UITableView {
    
    func autoSnapping(velocity: CGPoint, targetOffset: UnsafeMutablePointer<CGPoint>) {
        
        // er targetOffset perfekt på cellestart, do nothing
        if velocity.equalTo(CGPoint.zero) || targetOffset.pointee.y >= self.contentSize.height - self.frame.size.height - self.contentInset.top - self.contentInset.bottom {
            return
        }
        guard let indexPath = self.indexPathForRow(at: targetOffset.pointee) else {
            return
        }
        
        var offset = targetOffset.pointee
        let cellRect = self.rectForRow(at: indexPath)
        
        let targetOffsetYDif = offset.y - cellRect.minY
        if targetOffsetYDif < roundingHeight {
            offset.y = cellRect.minY - self.contentInset.top
        } else if targetOffsetYDif > cellRect.height - roundingHeight {
            offset.y = cellRect.maxY - self.contentInset.top
        }
        targetOffset.pointee = offset
    }
}
