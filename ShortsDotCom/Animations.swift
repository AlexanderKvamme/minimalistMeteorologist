//
//  Animations.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 29/10/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import Foundation
import UIKit

var loading_00000: UIImage!
var loading_00001: UIImage!
var loading_00002: UIImage!
var loading_00003: UIImage!
var loading_00004: UIImage!
var loading_00005: UIImage!
var loading_00006: UIImage!
var loading_00007: UIImage!
var loading_00008: UIImage!
var loading_00009: UIImage!
var loading_00010: UIImage!
var loading_00011: UIImage!
var loading_00012: UIImage!
var loading_00013: UIImage!
var loading_00014: UIImage!
var loading_00015: UIImage!
var loading_00016: UIImage!
var loading_00017: UIImage!
var loading_00018: UIImage!
var loading_00019: UIImage!
var loading_00020: UIImage!
var loading_00021: UIImage!
var loading_00022: UIImage!
var loading_00023: UIImage!
var loading_00024: UIImage!
var loading_00025: UIImage!
var loading_00026: UIImage!
var loading_00027: UIImage!
var loading_00028: UIImage!
var loading_00029: UIImage!
var loading_00030: UIImage!
var loading_00031: UIImage!
var loading_00032: UIImage!
var loading_00033: UIImage!
var loading_00034: UIImage!
var loading_00035: UIImage!
var loading_00036: UIImage!
var loading_00037: UIImage!
var loading_00038: UIImage!
var loading_00039: UIImage!
var loading_00040: UIImage!
var loading_00041: UIImage!
var loading_00042: UIImage!
var loading_00043: UIImage!
var loading_00044: UIImage!
var loading_00045: UIImage!
var loading_00046: UIImage!
var loading_00047: UIImage!
var loading_00048: UIImage!
var loading_00049: UIImage!
var loading_00050: UIImage!
var loading_00051: UIImage!
var loading_00052: UIImage!
var loading_00053: UIImage!
var loading_00054: UIImage!
var loading_00055: UIImage!
var loading_00056: UIImage!
var loading_00057: UIImage!
var loading_00058: UIImage!
var loading_00059: UIImage!
var loading_00060: UIImage!
var loading_00061: UIImage!
var loading_00062: UIImage!
var loading_00063: UIImage!
var loading_00064: UIImage!
var loading_00065: UIImage!
var loading_00066: UIImage!
var loading_00067: UIImage!
var loading_00068: UIImage!
var loading_00069: UIImage!
var loading_00070: UIImage!
var loading_00071: UIImage!
var loading_00072: UIImage!
var loading_00073: UIImage!
var loading_00074: UIImage!
var loading_00075: UIImage!
var loading_00076: UIImage!
var loading_00077: UIImage!
var loading_00078: UIImage!
var loading_00079: UIImage!

var checkmarkImages: [UIImage]!

class Animations{
    
    class func setupAnimation(){
        loading_00040 = UIImage(named: "loading_00040.png")
        loading_00041 = UIImage(named: "loading_00041.png")
        loading_00042 = UIImage(named: "loading_00042.png")
        loading_00043 = UIImage(named: "loading_00043.png")
        loading_00044 = UIImage(named: "loading_00044.png")
        loading_00045 = UIImage(named: "loading_00045.png")
        loading_00046 = UIImage(named: "loading_00046.png")
        loading_00047 = UIImage(named: "loading_00047.png")
        loading_00048 = UIImage(named: "loading_00048.png")
        loading_00049 = UIImage(named: "loading_00049.png")
        loading_00050 = UIImage(named: "loading_00050.png")
        loading_00051 = UIImage(named: "loading_00051.png")
        loading_00052 = UIImage(named: "loading_00052.png")
        loading_00053 = UIImage(named: "loading_00053.png")
        loading_00054 = UIImage(named: "loading_00054.png")
        loading_00055 = UIImage(named: "loading_00055.png")
        loading_00056 = UIImage(named: "loading_00056.png")
        loading_00057 = UIImage(named: "loading_00057.png")
        loading_00058 = UIImage(named: "loading_00058.png")
        loading_00059 = UIImage(named: "loading_00059.png")
        loading_00060 = UIImage(named: "loading_00060.png")
        loading_00061 = UIImage(named: "loading_00061.png")
        loading_00062 = UIImage(named: "loading_00062.png")
        loading_00063 = UIImage(named: "loading_00063.png")
        loading_00064 = UIImage(named: "loading_00064.png")
        loading_00065 = UIImage(named: "loading_00065.png")
        loading_00066 = UIImage(named: "loading_00066.png")
        loading_00067 = UIImage(named: "loading_00067.png")
        loading_00068 = UIImage(named: "loading_00068.png")
        loading_00069 = UIImage(named: "loading_00069.png")
        loading_00070 = UIImage(named: "loading_00070.png")
        loading_00071 = UIImage(named: "loading_00071.png")
        loading_00072 = UIImage(named: "loading_00072.png")
        loading_00073 = UIImage(named: "loading_00073.png")
        loading_00074 = UIImage(named: "loading_00074.png")
        loading_00075 = UIImage(named: "loading_00075.png")
        loading_00076 = UIImage(named: "loading_00076.png")
        loading_00077 = UIImage(named: "loading_00077.png")
        loading_00078 = UIImage(named: "loading_00078.png")
        loading_00079 = UIImage(named: "loading_00079.png")
        
        checkmarkImages = [loading_00040, loading_00041, loading_00042, loading_00043, loading_00044, loading_00045, loading_00046, loading_00047, loading_00048, loading_00049, loading_00050, loading_00051, loading_00052, loading_00053, loading_00054, loading_00055, loading_00056, loading_00057, loading_00058, loading_00059, loading_00060, loading_00061, loading_00062, loading_00063, loading_00064, loading_00065, loading_00066, loading_00067, loading_00068, loading_00069, loading_00070, loading_00071, loading_00072, loading_00073, loading_00074, loading_00075, loading_00076, loading_00077, loading_00078, loading_00079]
    }
    
    class func playCheckmarkOnce(inImageView imageView: UIImageView){
        
        imageView.animationImages = checkmarkImages
        imageView.animationDuration = 1
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
    }
    
    class func playCheckmarkAnimation(inImageView imageView: UIImageView){
        setupAnimation()
        playCheckmarkOnce(inImageView: imageView)
    }
    
}
