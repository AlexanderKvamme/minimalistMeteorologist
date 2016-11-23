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
    
    @IBOutlet weak var precipitationStackView: UIStackView!
    @IBOutlet weak var precipitationIconImageView: UIImageView!
    @IBOutlet weak var windSpeedUnitLabel: UILabel!
    @IBOutlet weak var windSpeedValueLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var firstLetterOfDayLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
