//
//  OrderHistoryCell.swift
//  kartCornor
//
//  Created by Srinivas on 26/09/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class OrderHistoryCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var orderIDLab: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.addBorderToview()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
