//
//  MyAddressVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class MyAddressVC: UIViewController {
    
    var jsonArr : NSArray = NSArray()
    @IBOutlet weak var addressTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        self.title = "My Saved Addresses"
        // Do any additional setup after loading the view.
       let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "burger")
               self.navigationItem.leftBarButtonItem = backBarButon
        //CACO26087
        addressTable.tableFooterView = UIView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        gettingAddress()
    }
    @objc func sideMenuAction() {
        sideMenuManager?.toggleSideMenuView()
    }
    func gettingAddress() {
        // guard let id = categoryDict["categoryid"] else {return}
        let userId = UserDefaults.standard.object(forKey: global.KUserId)
        let parameter : [String: Any] = ["userid" : userId!]
        ANLoader.showLoading("Please Wait", disableUI: true)
        global.api.postServerDataandgetResponse(urlString: global.getAddress, parameters: parameter) { (json) in
            // print(json);
            if (json.count == 0) {
                self.perform(#selector(self.sideMenuAction), with: nil, afterDelay: 4.0)
                DispatchQueue.main.async {
                    var style = ToastStyle()
                    // this is just one of many style options
                    style.messageColor = .red
                    style.backgroundColor = .lightGray
                    self.view.makeToast("data not found.Please Try Again", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true
                }
                return
            }
            self.jsonArr = json["myaddresses"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                print("the addressses are",json)
                self.addressTable.reloadData()
            }
        }
    }
}

extension MyAddressVC : UITableViewDataSource,UITableViewDelegate {
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
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let alert = UIAlertController(title: "Confirmation For Set Default Address", message: "D you want to Continue?", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (updateAction) in
                     //  self.list[indexPath.row] = alert.textFields!.first!.text!
                     //  self.tableView.reloadRows(at: [indexPath], with: .fade)
                       let dict : [String:Any] = self.jsonArr[indexPath.row] as! [String:Any]
                    UserDefaults.standard.set(dict, forKey: "defaultAddress")
                    self.setDefaultAddressItem(json: dict)
                   }))
                   alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                   self.present(alert, animated: false)
    }
    /*set default address
    userid:
    addressid:
    address:
    latlong:*/
    func setDefaultAddressItem(json:[String:Any]) {
        ANLoader.showLoading("Please Wait...", disableUI: true)
        let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,"addressid":json["addressid"]!,
        "address":json["address"]!,
        "latlong":json["latlong"]!]
        
        print(parameter)
        global.api.postServerDataandgetResponse(urlString: global.defaultAddress, parameters: parameter) { (json) in
            if (json.count == 0) {
                        DispatchQueue.main.async {
                            var style = ToastStyle()
                            // this is just one of many style options
                            style.messageColor = .red
                            style.backgroundColor = .lightGray
                            self.view.makeToast("data not found.Please Try Again", duration: 3.0, position: .bottom, style: style)
                            // toggle "tap to dismiss" functionality
                            ToastManager.shared.isTapToDismissEnabled = true
                        }
                        return
                    }
                    if json["error"] as! Int == 1 {
                        DispatchQueue.main.async { [unowned self] in
                            ANLoader.hide()
                            self.view.makeToast("Failed to set default Address", duration: 3.0, title: "", completion: nil)
                            print("Response data",json)
                        }
                    } else {
                        DispatchQueue.main.async { [unowned self] in
                            ANLoader.hide()
                            self.view.makeToast("Added as Default address", duration: 3.0, title: "", completion: nil)
                            print(json)
                        }
                    }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
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
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
            // delete item at indexPath
            
        }
        editAction.backgroundColor = .green
        delete.backgroundColor = .red
        return [editAction,delete]
    }
}


/*address = "1-33,Jennifer street,sri,putturu,opposite pond,parvathipuram,535527";
 addressid = FRAD35266;
 addressnickname = Cnu;
 defaulttype = 1;
 latlong = none;
 personname = "Srinivas ";
 }*/

/*set default address
 userid:
 addressid:
 address:
 latlong:*/
