//
//  DayHeaderCell.swift
//  FinalProject
//
//  Created by Noah Keller on 5/2/19.
//  Copyright © 2019 Mobile Computing. All rights reserved.
//

import Foundation
import UIKit

class DayHeaderCell: UITableViewCell{
    
    @IBOutlet weak var DayLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
