//
//  ContactUsVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class ContactUsVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        // Do any additional setup after loading the view.
        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        btnleft.setTitleColor(UIColor.white, for: .normal)
        btnleft.contentMode = .left
        
        btnleft.setImage(UIImage(named :"burger"), for: .normal)
        btnleft.addTarget(self, action: #selector(sideMenuAction), for: .touchDown)
        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)
        
        // self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        self.navigationItem.leftBarButtonItem = backBarButon
        
    }
    @objc func sideMenuAction() {
        sideMenuManager?.toggleSideMenuView()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func mailAction(_ sender: Any) {
        let email = "cartcornerinfo@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
        
    }
    @IBAction func callAction(_ sender: Any) {
        if let url = URL(string: "tel://917799154455"),
        UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
