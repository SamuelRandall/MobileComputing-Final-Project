//
//  HourlyCell.swift
//  FinalProject
//
//  Created by Noah Keller on 4/30/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import Foundation
import UIKit

class HourlyCell: UITableViewCell{
    
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirLabel: UILabel!
    @IBOutlet weak var rainChanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
