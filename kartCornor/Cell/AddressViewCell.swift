//
//  AddressViewCell.swift
//  kartCornor
//
//  Created by Srinivas on 16/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class AddressViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!{
        didSet {
            mainView.layer.cornerRadius = 10.0
            mainView.layer.shadowColor = UIColor.gray.cgColor
            mainView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            mainView.layer.shadowRadius = 6.0
            mainView.layer.shadowOpacity = 0.7
            mainView.layer.borderWidth = 0.3
            mainView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
   // @IBOutlet weak var editBtn: UIButton!
   // @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
