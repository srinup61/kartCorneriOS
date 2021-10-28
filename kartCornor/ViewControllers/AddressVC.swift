//
//  AddressVC.swift
//  kartCornor
//
//  Created by Srinivas on 28/09/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class AddressVC: UIViewController {
    var jsoncartArr = [NSDictionary]()
    var jsonArr : NSArray = NSArray()
    
    
    @IBOutlet weak var addNewAddress: UIButton!
    @IBOutlet weak var addressTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        // print("the cart data is ",jsonArr)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        gettingAddress()
        addNewAddress.addBorderToview()
        let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBarButon
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    func gettingAddress() {
        let userId = UserDefaults.standard.object(forKey: global.KUserId)!
        let parameter : [String: Any] = ["userid" : userId]
        ANLoader.showLoading("Please Wait", disableUI: true)
        global.api.postServerDataandgetResponse(urlString: global.getAddress, parameters: parameter) { (json) in
            // print(json);
            if (json.count == 0) {
                DispatchQueue.main.async {
                    var style = ToastStyle()
                    // this is just one of many style options
                    style.messageColor = .red
                    style.backgroundColor = .lightGray
                    self.view.makeToast("Please Add address to continue", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true
                }
                return
            }
            self.jsonArr = json["myaddresses"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                // print("the addressses are",json)
                self.addressTable.reloadData()
            }
        }
    }
    
    @IBAction func addressAction(_ sender: Any) {
        //newaddressVC
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : AddAddressVC = storyboard.instantiateViewController(withIdentifier: "newaddressVC") as! AddAddressVC
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}
extension AddressVC : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressViewCell
        let dict = jsonArr[indexPath.row] as! NSDictionary
        cell.nameLabel.text =  (dict["addressnickname"] as! String)
        cell.addressLabel.text = (dict["address"] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict  = jsonArr[indexPath.row] as! NSDictionary
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : PlaceOrderVC = storyboard.instantiateViewController(withIdentifier: "placeOrderVC") as! PlaceOrderVC
        itemView.addressDict = dict
        itemView.jsoncartArr = jsoncartArr
        itemView.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            itemView.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
        // self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Please Edit Address", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (updateAction) in
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let editVC = storyBoard.instantiateViewController(withIdentifier: "editAddress") as! editAddressVC
                editVC.addressDict = self.jsonArr[indexPath.row] as! NSDictionary
                self.navigationController?.pushViewController(editVC, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        return [editAction]
    }
}
/*{
 address = "1-23,currency nagar,mansion ,ramavarappadu,opposite government hospital,vijayawada,521108";
 addressid = FRAD47203;
 addressnickname = Aravind;
 defaulttype = 0;
 latlong = none;
 personname = Srinivas;
 }
 */
