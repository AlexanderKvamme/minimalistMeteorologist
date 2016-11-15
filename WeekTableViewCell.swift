//
//  WeekTableViewCell.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 08/11/2016.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//

import UIKit

class WeekTableViewCell: UITableViewCell {

    @IBOutlet weak var weekNumberLabel: UILabel!
    
    @IBAction func unwindToWeekTableViewController(segue: UIStoryboardSegue) {
    //
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
