//
//  MyCollectionViewCell.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 22/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

enum cellType{
    case image
    case text
    case animation
}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPrototype: UIImageView!
    @IBOutlet weak var textFieldPrototype: UITextView!
}
