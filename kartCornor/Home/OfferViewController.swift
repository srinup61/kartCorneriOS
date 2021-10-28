//
//  OfferViewController.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class OfferViewController: UIViewController {
    
    @IBOutlet weak var offerTable: UITableView!
    var offerArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        offerTable.tableFooterView = UIView()
        self.title = "Offers"
        let backBtn = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBtn
        // Do any additional setup after loading the view.
        ANLoader.showLoading("Please Wait", disableUI: true)
        global.api.gettingServerResponse(urlString: global.offers) { (json) in
            print("slide data is ",json)
            if json.count == 0 {
                self.callingToast()
                return
            }
            self.offerArray = json["offers"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                self.offerTable.reloadData()
            }
        }
    }
    func callingToast() {
        DispatchQueue.main.async {
            var style = ToastStyle()
            // this is just one of many style options
            style.messageColor = .red
            style.backgroundColor = .lightGray
            self.view.makeToast("data not found.Please Try Again", duration: 3.0, position: .bottom, style: style)
            // toggle "tap to dismiss" functionality
            ToastManager.shared.isTapToDismissEnabled = true
        }
    }
    @objc func sideMenuAction() {
       // self.navigationController?.popViewController(animated: true)
        self.navigationController?.dismiss(animated: false, completion:nil)
    }
}

extension OfferViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : OfferTableViewCell = offerTable.dequeueReusableCell(withIdentifier: "offerCell", for: indexPath) as! OfferTableViewCell
        let offerDict : NSDictionary = offerArray[indexPath.row] as! NSDictionary
        
        let offerCde : String = offerDict["offerCode"] as! String
        let offerName : String = offerDict["offerName"] as! String
        let offerDesc : String = offerDict["offerNote"] as! String
        let offerDate : String = offerDict["offerValidupto"] as! String
        
        cell.codeLabel.text = "CODE :" + offerCde
        cell.offerName.text = offerName
        cell.descLabel.text = offerDesc
        cell.dateLabel.text = "Valid Upto:" + offerDate
        return cell
    }
}
/*{
 "id": 1,
 "offerId": "CAFF2020",
 "offerName": "GET RS 50/- OFF",
 "offerCode": "GET50",
 "offerType": "off",
 "offerPrice": 50,
 "offerPercentage": 0,
 "offerNote": "offer valid only for minimum order amount of 300",
 "offerAmountlimit": 50,
 "offerValidupto": "25-07-2020",
 "offerInserteddate": "24-07-2020"
 }*/
