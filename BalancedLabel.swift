//
//  BalancedLabel.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 10/01/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

class BalancedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        
        self.textAlignment = .center
        
        var rect2 = CGRect.zero
        print("Start")
        print("Initial rect: ", rect)
        
        if self.textAlignment == .center {
            
            print("is centered")
            
            let oneLineRect: CGRect = self.textRect(forBounds: CGRect.infinite, limitedToNumberOfLines: 1)
            let numberOfLines = ceil(oneLineRect.size.width / self.bounds.size.width)
            var betterWidth = (oneLineRect.size.width / numberOfLines)
            
            if (betterWidth < rect.size.width) {
                
                var check = CGRect.zero
                /*
                 repeat {
                 betterWidth = betterWidth * 1.1
                 let b = CGRect(x: 0, y: 0, width: betterWidth, height: CGRect.infinite.size.height)
                 check = textRect(forBounds: b, limitedToNumberOfLines: 0)
                 print("betterWidth: ", betterWidth)
                 
                 } while (check.size.height > rect.size.height && betterWidth < rect.size.width)
                 
                 */
                
                while (check.size.height > rect.size.height && betterWidth < rect.size.width) {
                    betterWidth = betterWidth * 1.1
                    let b = CGRect(x: 0, y: 0, width: betterWidth, height: CGRect.infinite.size.height)
                    check = textRect(forBounds: b, limitedToNumberOfLines: 0)
                    print("betterWidth: ", betterWidth)
                    
                }
                if (betterWidth < rect.size.width) {
                    let difference = rect.size.width - betterWidth
                    rect2 = CGRect(x: rect.origin.x + difference/2.0, y: rect.origin.y, width: betterWidth, height: rect.size.height)
                    print(rect2)
                }
            }
            
        } else {
            print("not centered")}
        super.drawText(in: rect2)
    }
}
