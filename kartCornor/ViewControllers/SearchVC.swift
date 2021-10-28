//
//  SearchVC.swift
//  kartCornor
//
//  Created by Srinivas on 18/10/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke

class SearchVC: UIViewController {
    
    
    var itemDict : NSDictionary = NSDictionary()
    var itemArray = NSArray()
    var priceData  = NSAttributedString()
    var jsonDict = [Dictionary<String,Any>]()
    var priceID : Int = Int()
    @IBOutlet weak var itemTable: UITableView!
    var allProducts = [[String : Any]]()
    var itemDesc = NSDictionary()
    var suggestionArray = Array<String>()
    var itemName  = ""
    let serialQueue = DispatchQueue(label: "queuename")
    
    var jsonArr = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("the search data is",jsonArr)
        // Do any additional setup after loading the view.
        self.navigationController?.addcolorToBar()
        self.title = "items"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16)!]
        let cartBtn = UIBarButtonItem.menuButton(self, action: #selector(cartView), imageName: "shop")
        self.navigationItem.rightBarButtonItem = cartBtn
        let badgeCount = UserDefaults.standard.string(forKey: "badgeData")
        if badgeCount == "0" || badgeCount?.isEmpty ?? true{
            cartBtn.removeBadge()
        } else {
            cartBtn.addBadge(text: badgeCount!)
        }
        let backBtn = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBtn
        // Do any additional setup after loading the view.
        print("the selected item dict is",itemDict)
        guard let catId = itemDict["productcatid"] else {
            return
        }
        guard let subcatId = itemDict["productsubcatid"] else {
            return
        }
        let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId]
        ANLoader.showLoading("Please Wait", disableUI: true)
        serialQueue.sync {
            global.api.postServerDataandgetResponse(urlString: global.getProducts, parameters: parameter) { (json) in
                if (json.count < 1) {
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
                self.itemArray = json["products"] as! NSArray
                DispatchQueue.main.async { [unowned self] in
                    ANLoader.hide()
                    // self.tagViewCustomization()
                    self.itemTable.reloadData()
                }
            }
        }
    }
    @objc func cartView() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : ShoppingCartVC = storyboard.instantiateViewController(withIdentifier: "cartVC") as! ShoppingCartVC
        let nav = UINavigationController(rootViewController: itemView)
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.dismiss(animated: false, completion:nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemDescriptionVC" {
            let cell = sender as! UITableViewCell
            if let indexPath = self.itemTable.indexPath(for: cell) {
                let controller = segue.destination as! itemDescriptionVC
                var dict = NSDictionary ()
                if indexPath.section == 0 {
                    dict = itemDict
                } else {
                    dict = itemArray[indexPath.row] as! NSDictionary
                }
                controller.itemDict = dict
                controller.titleStr = dict["productname"] as! String
            }
        }
    }
}
extension SearchVC : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! itemTableViewCell
        var dict = NSDictionary ()
        if indexPath.section == 0 {
            dict = itemDict
        } else {
            dict = itemArray[indexPath.row] as! NSDictionary
        }
        let imgStr = global.imgUrl + (dict["productimage"]  as! String)
        print(imgStr)
        let url = URL(string: imgStr)
        if url == nil {
            cell.itemImage.image = UIImage(named: "noimage.jpg")
        } else {
            Nuke.loadImage(with: url!, into: cell.itemImage)
        }
        let brandName = dict["productname"] as! String
        cell.titleLabel.text = brandName
        cell.detailTextLabel?.isHidden = false
        cell.countLabel.tag = (indexPath.section * 10) + indexPath.row
        cell.stepper.tag = (indexPath.section*10)+indexPath.row
        cell.cartButton.tag = (indexPath.section*10)+indexPath.row
        cell.stepper.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        cell.cartButton.addTarget(self, action: #selector(cartButtonAction(_:)), for: .touchUpInside)
        cell.cartButton.addBorderToview()
        
        let data = (dict["productprice"] as! String).data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                let priceArray = makeProductPriceArray(jsondict: jsonArray)
                //   print("the price array is",priceArray)
                if priceArray.count == 0 {
                    cell.dropDownMenu.optionArray = priceArray
                    cell.dropDownMenu.text = "Out of Stock"
                } else {
                    cell.dropDownMenu.optionArray = priceArray
                    cell.dropDownMenu.attributedText = priceArray[0]
                }
                jsonDict = jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        // The the Closure returns Selected Index and String
        cell.dropDownMenu.didSelect{(selectedText , index ,id) in
            self.priceData = selectedText
            self.priceID = index
            cell.countLabel.text = "1"
        }
        //  print(dict)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let cell = sender as! UITableViewCell
       // if let indexPath = self.itemTable.indexPath(for: cell) {
         //   let controller = segue.destination as! itemDescriptionVC
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let itemView = storyBoard.instantiateViewController(withIdentifier: "itemDesc") as! itemDescriptionVC
            var dict = NSDictionary ()
            if indexPath.section == 0 {
                dict = itemDict
            } else {
                dict = itemArray[indexPath.row] as! NSDictionary
            }
        itemView.itemDict = dict
        itemView.titleStr = dict["productname"] as! String
        let nav = UINavigationController(rootViewController: itemView)
        self.present(nav, animated: true, completion: nil)

    }
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    @objc  func valueChanged(_ step :UIStepper) {
        //  print("The values are", step.value)
        let section = step.tag / 100
        let row = step.tag % 100
        let indexPath = NSIndexPath(row: row, section: section)
        //  print(indexPath.row)
        let cell = itemTable.cellForRow(at: indexPath as IndexPath) as! itemTableViewCell
        cell.countLabel.text = Int(step.value).description
    }
    func makeProductPriceArray(jsondict : [Dictionary<String,Any>]) -> [NSAttributedString] {
        var priceArr = [NSAttributedString]()
        for finalDict in jsondict {
            let priceStr =  String(describing: finalDict["productWeight"]!)
            let discPrice = String(describing: finalDict["productDPrice"]!)
            let origPrice = String(describing: finalDict["productPrice"]!)
            
            // let attributeString = strikeOnLabel(priceStr: origPrice as NSString)
            
            //  print("the striked value is ", attributeString)
            let orgPrice = "\u{20B9}" + origPrice
            let discountPrice = "\u{20B9}" + discPrice
            
            let resultStr = "\(priceStr) , \(orgPrice) , \(discountPrice)"
            // print("caling dump data",getAttributedStrings(text: resultStr))
            priceArr.append(getAttributedStrings(text: resultStr))
        }
        return priceArr
    }
    
    func getAttributedStrings(text: String) -> NSAttributedString {
        
        let words:[String] = text.components(separatedBy: " , ")
        
        var attribWords = [NSAttributedString]()
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)]
        
        let attr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.strikethroughColor: UIColor.black,
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)] as [NSAttributedString.Key : Any]
        
        for i in 0...words.count - 1 {
            var tempStr = NSAttributedString()
            if i == 1 {
                tempStr = NSAttributedString(string: words[i], attributes: attr)
            } else {
                tempStr = NSAttributedString(string: words[i], attributes: attributes)
            }
            attribWords.append(tempStr)
        }
        // print("attrib words",attribWords)
        let attribString = NSMutableAttributedString()
        for i in 0 ... attribWords.count - 1 {
            attribString.append(NSAttributedString(string: "  "))
            attribString.append(attribWords[i])
        }
        return attribString
    }
    func strikeOnLabel(priceStr : NSString) -> NSAttributedString {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "INR"
        let priceInINR = currencyFormatter.string(from: priceStr.integerValue as NSNumber)
        
        let attributedString = NSMutableAttributedString(string: priceInINR!)
        //  print("the striked value is ", attributedString)
        // Swift 4.2 and above
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    @objc func cartButtonAction(_ btn:UIButton) {
        let section = btn.tag / 100
        let row = btn.tag % 100
        let indexPath = NSIndexPath(row: row, section: section)
        // print(indexPath.row)
        let cell = itemTable.cellForRow(at: indexPath as IndexPath) as! itemTableViewCell
        print(cell.countLabel.text!)
        var dict = NSDictionary()
        
        if indexPath.section == 0 {
            dict = itemDict
        } else {
            dict = itemArray[indexPath.row] as! NSDictionary
        }
        //  var priceDict = NSDictionary()
        //   DispatchQueue.main.async { [unowned self] in
        // write your code here
        let data = (dict["productprice"] as! String).data(using: .utf8)!
        do {
            if let priceArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                let priceDict = priceArray[0]
                ANLoader.showLoading("Adding to cart", disableUI: true)
                
                let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,
                                                 "priceid":priceDict["priceId"]!,
                                                 "productid":dict["productid"]!,
                                                 "productname":dict["productname"]!,
                                                 "productprice":priceDict["productPrice"]!,
                                                 "productdiscountprice":priceDict["productDPrice"]!,
                                                 "productquantity":priceDict["productQuantity"]!,
                                                 "productweight":priceDict["productWeight"]!,
                                                 "productimage":dict["productimage"]!,
                                                 "productquno":cell.countLabel.text!]
                print(parameter)
                global.api.postServerDataandgetResponse(urlString: global.addtoCart, parameters: parameter) { (json) in
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
                            self.view.makeToast("Failed to add Cart", duration: 3.0, title: "", completion: nil)
                            print("Response data",json)
                        }
                    } else {
                        DispatchQueue.main.async { [unowned self] in
                            ANLoader.hide()
                            self.view.makeToast("Added to Cart", duration: 3.0, title: "", completion: nil)
                            print("Response data",json)
                        }
                    }
                }
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        // }
    }
}
