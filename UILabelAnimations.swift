//
//  UILabelAnimations.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 03/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func fadeIn() {
        UIView.animate(withDuration: 0.15) {
            self.alpha = 1
        }
    }
}
