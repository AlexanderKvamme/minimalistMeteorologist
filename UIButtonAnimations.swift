//
//  UIViewAnimations.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 03/05/2017.
//  Copyright © 2017 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func turnWhite() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = .white
        }
    }
}
