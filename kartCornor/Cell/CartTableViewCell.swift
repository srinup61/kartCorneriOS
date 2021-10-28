//
//  CartTableViewCell.swift
//  kartCornor
//
//  Created by Srinivas on 16/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgView: UIImageView!
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
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var stepperLabel: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
