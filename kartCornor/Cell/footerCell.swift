//
//  footerCell.swift
//  kartCornor
//
//  Created by Srinivas on 07/10/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class footerCell: UICollectionReusableView {
    
    @IBOutlet weak var footerImages: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        // self.backgroundColor = UIColor.purple
        
        // Customize here
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
