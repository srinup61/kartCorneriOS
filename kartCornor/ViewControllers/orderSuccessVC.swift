//
//  orderSuccessVC.swift
//  kartCornor
//
//  Created by Srinivas on 11/10/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class orderSuccessVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        // Do any additional setup after loading the view.
       // self.navigationController?.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        descLabel.text = "Order Placed Successfully"
    }

    @IBOutlet weak var descLabel: UILabel!
    @IBAction func continueToHome(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! SMNavigationController
        appDelegate.window?.rootViewController = loginVC
    }
    
}
