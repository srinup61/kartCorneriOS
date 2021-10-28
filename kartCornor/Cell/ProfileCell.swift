//
//  ProfileCell.swift
//  kartCornor
//
//  Created by Srinivas on 30/07/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var headLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        mainView.addBorderToview()
        // Configure the view for the selected state
    }

}
