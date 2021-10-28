//
//  MonthlyCartVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke

class MonthlyCartVC: UIViewController {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var placeOrder: UIButton!
    @IBOutlet weak var cartTable: UITableView!
    
    var typeStr :String = ""
    var costStr = 0
    var jsonArr  = [NSDictionary]()
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // bottomView.applyGradientView()
        cartTable.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        self.title = "Monthly Cart Items"
        self.navigationController?.addcolorToBar()
        var backBarButon = UIBarButtonItem()
        print(UserDefaults.standard.bool(forKey: "sidemenu"))
        if UserDefaults.standard.bool(forKey: "sidemenu") {
            backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "burger")
        } else {
            backBarButon = UIBarButtonItem.menuButton(self, action: #selector(addbackButton), imageName: "back")
        }
        self.navigationItem.leftBarButtonItem = backBarButon
        gettingCartItems()
    }
    func gettingCartItems() {
        // guard let id = categoryDict["categoryid"] else {return}
        let userId = UserDefaults.standard.object(forKey: global.KUserId)
        let parameter : [String: Any] = ["userid" : userId!]
        costStr = 0
        ANLoader.showLoading("Please Wait", disableUI: true)
        global.api.postServerDataandgetResponse(urlString: global.monthCart, parameters: parameter) { (json) in
            // print(json);
            if (json.count == 0) {
                DispatchQueue.main.async {
                    var style = ToastStyle()
                    // this is just one of many style options
                    style.messageColor = .red
                    style.backgroundColor = .lightGray
                    self.view.makeToast("Please Try Again", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                    UserDefaults.standard.set("0", forKey: "monthbadgeData")
                    self.placeOrder.isUserInteractionEnabled = false
                    ToastManager.shared.isTapToDismissEnabled = true
                    self.jsonArr = []
                    self.cartTable.reloadData()
                }
                return
            }
            self.jsonArr = json["cartitems"] as! [NSDictionary]
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                let badgeCount = self.jsonArr.count
                UserDefaults.standard.set(badgeCount, forKey: "monthbadgeData")
                print("sub category data",json)
                for dict in self.jsonArr {
                    if (dict["productprice"] is NSNull) {
                        
                    } else {
                        let productQ = (dict["productquno"] as! Int)
                        let productP = dict["productdiscountprice"] as! Int
                        let total = (productP * productQ)
                        costStr = costStr + total
                    }
                }
                totalLabel.text = "RS."+String(costStr)
                self.cartTable.reloadData()
            }
        }
    }
    @objc func sideMenuAction() {
        sideMenuManager?.toggleSideMenuView()
    }
    @objc func addbackButton() {
        self.navigationController?.dismiss(animated: false, completion:nil)
    }
    
    @IBAction func orderAction(_ sender: Any) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : AddressVC = storyboard.instantiateViewController(withIdentifier: "userAddress") as! AddressVC
        print("teh carat data sharing",jsonArr)
        itemView.jsoncartArr = jsonArr
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
}
extension MonthlyCartVC : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if jsonArr.count == 0 {
            tableView.setEmptyView(title: "You don't have any items in cart.", message: "Add items to Cart.")
        }
        else {
            tableView.restore()
        }
        return jsonArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "monthcartCell", for: indexPath) as! CartTableViewCell
        let dict : [String:Any] = jsonArr[indexPath.row] as! [String:Any]
        cell.nameLabel.text = (dict["productname"] as! String)
        
        cell.weightLabel.text = String(describing: dict["productquantity"]!) + "*" + String(describing: dict["productweight"]!)
        
        if (dict["productprice"] is NSNull) {
            cell.costLabel.text = "0"
        } else {
            let productQ = (dict["productquno"] as! Int)
            
            let productP = dict["productdiscountprice"] as! Int
            let total = (productP * productQ)
            cell.costLabel.text = String(total)
           // costStr = costStr + total
        }
        cell.stepperLabel.tag = (indexPath.section * 10) + indexPath.row
        cell.stepper.tag = (indexPath.section*10)+indexPath.row
        
        cell.stepperLabel.text = String(describing: dict["productquno"]!)
        cell.stepper.value = dict["productquno"] as! Double
        cell.stepper.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        
        //let imgStr = global.imgUrl + (dict["productimage"]  as! String)
        var imgStr = ""
        if (dict["productimage"]  as! String).contains(global.imgUrl) {
            imgStr = (dict["productimage"]  as! String)
        } else {
            imgStr = global.imgUrl + (dict["productimage"]  as! String)
        }
        let url = URL(string: imgStr)
        if url == nil {
            cell.imgView.image = UIImage(named: "noimage.jpg")
        } else {
            Nuke.loadImage(with: url!, into: cell.imgView)
        }
       // totalLabel.text = "RS."+String(costStr)
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Delete cart item", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (updateAction) in
                let dict : [String:Any] = self.jsonArr[indexPath.row] as! [String:Any]
                self.deleteItem(json: dict)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
            
        }
        delete.backgroundColor = .red
        return [delete]
    }
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func deleteItem(json:[String:Any]) {
        ANLoader.showLoading("Please Wait...", disableUI: true)
        let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,"productid":json["productid"]!,"cartModel":"month"]
        global.api.postServerDataandgetResponse(urlString: global.deleteCartItem, parameters: parameter) { (json) in
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
                    self.view.makeToast("Failed to delete Item", duration: 3.0, title: "", completion: nil)
                    print("Response data",json)
                }
            } else {
                DispatchQueue.main.async { [unowned self] in
                    ANLoader.hide()
                    self.view.makeToast("Item deleted from Cart", duration: 3.0, title: "", completion: nil)
                    self.gettingCartItems()
                    
                    self.cartTable.reloadData()
                  //  print("cart data",json)
                }
            }
        }
    }
    
    @objc  func valueChanged(_ step :UIStepper) {
        print("The values are", step.value)
        let section = step.tag / 100
        let row = step.tag % 100
        let indexPath = NSIndexPath(row: row, section: section)
        //  print(indexPath.row)
        let dict : [String:Any] = jsonArr[indexPath.row] as! [String:Any]
        let cell = cartTable.cellForRow(at: indexPath as IndexPath) as! CartTableViewCell
        let tempStr = (cell.stepperLabel?.text?.toDouble())!
        
        if step.value > tempStr {
            typeStr = "plus"
        } else {
            typeStr = "minus"
        }
        
        cell.stepperLabel.text = Int(step.value).description
        ANLoader.showLoading("Please Wait...", disableUI: true)
        let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,
                                         "productid":dict["productid"]!,
                                         "quantity":cell.stepperLabel.text!,
                                         "type":typeStr,
                                         "cartType":"monthlycart"]
        print(parameter)
        
        global.api.postServerDataandgetResponse(urlString: global.updateCart, parameters: parameter) { (json) in
            // print(json);
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
                    self.view.makeToast("Failed to update Cart", duration: 3.0, title: "", completion: nil)
                    print("Response data",json)
                }
            } else {
                DispatchQueue.main.async { [unowned self] in
                    ANLoader.hide()
                    //  self.view.makeToast("Cart Updated", duration: 3.0, title: "", completion: nil)
                    self.gettingCartItems()
                    print("cart data",json)
                }
            }
        }
        
    }
}

//delete Data
/*userid:
 productid:*/
