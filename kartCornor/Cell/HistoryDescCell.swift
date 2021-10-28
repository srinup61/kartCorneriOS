//
//  HistoryDescCell.swift
//  kartCornor
//
//  Created by Srinivas on 26/09/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class HistoryDescCell: UITableViewCell {

    @IBOutlet weak var priceLab: UILabel!
    @IBOutlet weak var quantityLab: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var mainView: UIView!
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
