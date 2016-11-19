//
//  DayTableViewCell.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 19/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var firstLetterOfDayLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
