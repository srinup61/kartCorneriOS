//
//  ShoppingCartVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke
import Alamofire

class ShoppingCartVC: UIViewController {
    
    @IBOutlet weak var cartTable: UITableView!
    var jsonArr = [NSDictionary]()
    var typeStr :String = ""
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var placeOrder: UIButton!
    var costStr = 0
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // bottomView.applyGradientView()
        self.navigationController?.addcolorToBar()
        cartTable.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        self.title = "Cart Items"
        var backBarButon = UIBarButtonItem()
        // print(UserDefaults.standard.bool(forKey: "sidemenu"))
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
        ANLoader.showLoading("Please Wait", disableUI: true)
        costStr = 0
        global.api.postServerDataandgetResponse(urlString: global.cartItems, parameters: parameter) { (json) in
            // print(json);
            if (json.count == 0) {
                DispatchQueue.main.async {
                    var style = ToastStyle()
                    // this is just one of many style options
                    style.messageColor = .red
                    style.backgroundColor = .lightGray
                    self.placeOrder.isUserInteractionEnabled = false
                    self.view.makeToast("Please Try Again", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true
                    UserDefaults.standard.set("0", forKey: "badgeData")
                    self.jsonArr = []
                    self.cartTable.reloadData()
                }
                return
            }
            self.jsonArr = json["cartitems"] as! [NSDictionary]
          //  print("the cart items are",self.jsonArr)
            UserDefaults.standard.set(self.jsonArr, forKey: "cartData")
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                print("sub category data",json)
                let badgeCount = self.jsonArr.count
                UserDefaults.standard.set(badgeCount, forKey: "badgeData")
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
extension ShoppingCartVC : UITableViewDataSource , UITableViewDelegate{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        let dict : [String:Any] = jsonArr[indexPath.row] as! [String:Any]
        cell.nameLabel.text = (dict["productname"] as! String)
        
        cell.weightLabel.text = String(describing: dict["productquno"]!) + "*" + String(describing: dict["productweight"]!)
        
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
        // let imgStr = global.imgUrl + (dict["productimage"]  as! String)
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
        
        return cell
    }
    //userid:
    //productid:
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
    func deleteAction(sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.cartTable)
        let indexPath = self.cartTable.indexPathForRow(at: buttonPosition)
        let dict1 : [String:Any] = self.jsonArr[indexPath!.row] as! [String:Any]
        print("First button tapped")
        self.deleteItem(json: dict1)
    }
    func deleteItem(json:[String:Any]) {
        ANLoader.showLoading("Please Wait...", disableUI: true)
        let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,"productid":json["productid"]!,"cartModel":"shop"]
        global.api.postServerDataandgetResponse(urlString: global.deleteCartItem, parameters: parameter) { (json) in
            if (json.count == 0) {
                DispatchQueue.main.async {
                    var style = ToastStyle()
                    // this is just one of many style options
                    style.messageColor = .red
                    style.backgroundColor = .lightGray
                    self.view.makeToast("Please Try Again", duration: 3.0, position: .bottom, style: style)
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
                    // print("cart data",json)
                }
            }
        }
    }
    /*userid:
     productid:
     quantity:
     type:
     cartType:*/
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
                                         "cartType":"cartitems"]
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
                    //   self.cartTable.reloadData()
                    print("cart data",json)
                }
            }
        }
        
    }
    
}
/*{
 "cartitems": [
 {
 "userid": "CACO22830",
 "priceid": "1",
 "productid": "19FK3502",
 // "productname": "Annapurna Aata",
 //  "productprice": null,
 "productdiscountprice": null,
 // "productquantity": "2",
 "productquno": 4,
 // "productweight": "1 KG",
 "productimage": ""
 }
 ]
 }*/
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}


//weeklycart
//monthlycart
extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
