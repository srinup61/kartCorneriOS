//
//  itemDescriptionVC.swift
//  kartCornor
//
//  Created by Srinivas on 12/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke
class itemDescriptionVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var stepper: UIStepper!
    var itemDict : NSDictionary = NSDictionary()
    var jsonDict = [Dictionary<String,Any>]()
    @IBOutlet weak var dropDown: DropDown!
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var stepperLabel: UILabel!
    @IBOutlet weak var titeLable: UILabel!
    var priceData  = NSAttributedString()
    var priceID : Int = Int()
    
    var titleStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
       // cartButton.applyGradient()
        // print(itemDict)
        //productname
        self.navigationController?.navigationBar.topItem?.title = "Item Description"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16)!]
        self.title = titleStr
        
        mainView.addBorderToview()
        // Do any additional setup after loading the view.
        //let imgStr = global.imgUrl + (itemDict["productimage"]  as! String)
        
        guard let prodId = itemDict["productimage"] else {
            return
        }
        
        var imgStr = ""
        if (prodId  as! String).contains(global.imgUrl) {
            imgStr = (itemDict["productimage"]  as! String)
        } else {
            imgStr = global.imgUrl + (itemDict["productimage"]  as! String)
        }
        let url = URL(string: imgStr)
        if url == nil {
            imgView.image = UIImage(named: "noimage.jpg")
        } else {
            Nuke.loadImage(with: url!, into: imgView)
        }
        //  DispatchQueue.global(qos: .background).async { [self] in
        DispatchQueue.main.async { [unowned self] in
            self.addingData()
        }
    }
    func loggedin() {
        // Add a text field
        if   UserDefaults.standard.bool(forKey: global.KUserLogged) {
            return
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            // loginVC.pre
            loginVC.modalPresentationStyle = .overCurrentContext
            loginVC.providesPresentationContextTransitionStyle = true
            loginVC.definesPresentationContext =  true
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        imgView.image = nil
    }
    func addingData(){
        let backBtn = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBtn
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        let cartBtn = UIBarButtonItem.menuButton(self, action: #selector(cartView), imageName: "shop")
        self.navigationItem.rightBarButtonItem = cartBtn
        let badgeCount = UserDefaults.standard.string(forKey: "badgeData")
        if badgeCount == "0" || badgeCount?.isEmpty ?? true {
            cartBtn.removeBadge()
        } else {
            cartBtn.addBadge(text: badgeCount!)
        }
        } else {
            let monthCart = UIBarButtonItem.menuButton(self, action: #selector(loginView), imageName: "login")
            self.navigationItem.rightBarButtonItems = [monthCart]
        }
        titeLable.text =  String(describing: itemDict["productname"]!)
        descriptionlabel.text = String(describing: itemDict["productdesc"]!)
        let data = (itemDict["productprice"] as! String).data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                jsonDict = jsonArray
                let priceArray = makeProductPriceArray(jsonDict: jsonArray)
                print("the price array is",priceArray)
                // dropDown.optionArray = priceArray
                // dropDown.text = priceArray[0]
                if priceArray.count == 0 {
                    dropDown.optionArray = priceArray
                    dropDown.text = "Out of Stock"
                } else {
                    dropDown.optionArray = priceArray
                    dropDown.attributedText = priceArray[0]
                }
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        // The the Closure returns Selected Index and String
        dropDown.didSelect{(selectedText , index ,id) in
            self.priceData = selectedText
            self.priceID = index
            self.stepperLabel.text = "1"
        }
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        //  self.navigationController?.popToRootViewController(animated: true)
        //  self.dismiss(animated: false, completion:nil)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @objc func loginView() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
         loginVC.modalPresentationStyle = .overCurrentContext
         loginVC.providesPresentationContextTransitionStyle = true
         loginVC.definesPresentationContext =  true
         self.present(loginVC, animated: true, completion: nil)
     }
    @objc func cartView() {
            print("Cartiew")
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let itemView : ShoppingCartVC = storyboard.instantiateViewController(withIdentifier: "cartVC") as! ShoppingCartVC
            let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
    }
    @IBAction func stepperAction(_ sender: UIStepper) {
        stepperLabel.text = Int(sender.value).description
    }
    func makeProductPriceArray(jsonDict : [Dictionary<String,Any>]) -> [NSAttributedString] {
        var priceArr = [NSAttributedString]()
        for finalDict in jsonDict {
            let priceStr =  String(describing: finalDict["productWeight"]!)
            let discPrice = String(describing: finalDict["productDPrice"]!)
            let origPrice = String(describing: finalDict["productPrice"]!)
            let orgPrice = "\u{20B9}" + origPrice
            let discountPrice = "\u{20B9}" + discPrice
            
            let resultStr = "\(priceStr) , \(orgPrice) , \(discountPrice)"
            print("caling dump data",getAttributedStrings(text: resultStr))
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
        print("the striked value is ", attributedString)
        // Swift 4.2 and above
        attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    @IBAction func cartButtonAction(_ sender: Any) {
        // print(priceData)
        // print(itemDict)
        //  print(jsonDict[priceID])
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        ANLoader.showLoading("Adding to cart", disableUI: true)
        let finalDict = jsonDict[0]
        let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,
                                         "priceid":finalDict["priceId"]!,
                                         "productid":itemDict["productid"]!,
                                         "productname":itemDict["productname"]!,
                                         "productprice":finalDict["productPrice"]!,
                                         "productdiscountprice":finalDict["productDPrice"]!,
                                         "productquantity":finalDict["productQuantity"]!,
                                         "productweight":finalDict["productWeight"]!,
                                         "productimage":itemDict["productimage"]!,
                                         "productquno":stepperLabel.text!]
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
            self.loggedin()
        }
    }
}
/*userid:CACO22830
 priceid:1
 productid:19FK3502
 productname:Annapurna Aata
 productprice:70
 productdiscountprice:68
 productquantity:2
 productquno:2
 productweight:1 KG
 productimage:*/
/*{
 "productid": "CAID580296537",
 "productname": "Tomatoes",
 "productprice": "[{\"productPrice\":\"35\",\"productDPrice\":\"30\",\"productWeight\":\"1 KG\",\"productQuantity\":\"1\",\"priceId\":\"CAPD1410172270\"},{\"productPrice\":\"22\",\"productDPrice\":\"20\",\"productWeight\":\"500 GMS\",\"productQuantity\":\"1\",\"priceId\":\"CAPD1618380557\"}]",
 "productcatid": 301,
 "productsubcatid": 5,
 "productinstock": 1,
 "productimage": "011970000000tomato-hybrid.jpg",
 "productdesc": "Hello"
 }*/
