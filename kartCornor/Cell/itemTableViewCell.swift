//
//  itemTableViewCell.swift
//  kartCornor
//
//  Created by Srinivas on 07/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class itemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var mainView: UIView! {
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
    
    
    @IBOutlet weak var dropDownMenu: DropDown!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
/*@IBOutlet
weak var containerView: UIView! {
    didSet {
        containerView.backgroundColor = UIColor.clear
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor(named: "Orange")?.cgColor
        containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
}*/
