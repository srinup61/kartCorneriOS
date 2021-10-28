//
//  PlaceOrderVC.swift
//  kartCornor
//
//  Created by Srinivas on 30/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Alamofire
import AppInvokeSDK

class PlaceOrderVC: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var descView: UIView!
    
    
    @IBOutlet weak var placeorderLab: UILabel!
    @IBOutlet weak var addressLab: UILabel!
    @IBOutlet weak var locationLab: UILabel!
    
    @IBOutlet weak var changeDeliverBtn: UIButton!
    
    @IBOutlet weak var deliveryText: UILabel!
    
    @IBOutlet weak var dropDown1: DropDown!
    @IBOutlet weak var dropDown2: DropDown!
    
    @IBOutlet weak var promoLabel: UILabel!
    
    @IBOutlet weak var promoText: UITextField!
    @IBOutlet weak var promoAction: UIButton!
    
    @IBOutlet weak var orderItemText: UILabel!
    @IBOutlet weak var deliverydateText: UILabel!
    @IBOutlet weak var deliveryTimeText: UILabel!
    @IBOutlet weak var orderCostText: UILabel!
    @IBOutlet weak var savingCostText: UILabel!
    @IBOutlet weak var deliveryChargeText: UILabel!
    
    @IBOutlet weak var totalAmtText: UILabel!
    
    @IBOutlet weak var choosePaymentBtn: UIButton!
    @IBOutlet weak var placeOrderBtn: UIButton!
    
    @IBOutlet var radioBtn: [radioButton]!
    
    var jsonVal = String()
    var cartArr = [NSMutableDictionary]()
    var offers = [String]()
    var pincodeStr = ""
    var addressDict = NSDictionary()
    
    var totalAmt = 0
    var discountTotAmt = 0
    var deliveryChares = 0
    var jsoncartArr = [NSDictionary]()
    
    @IBOutlet weak var containerView: UIView!
    var payStr = ""
    
    var typeStr = ""
    var dayStr = NSAttributedString()
    var timeStr = NSAttributedString()
    var dayArray = [String]()
    var timeArray = ["6AM - 9AM", "9AM - 2PM", "2PM - 7PM"]
    var params = [String:String]()
    
    // New method
   // var txnController = PGTransactionViewController()
  //  var serv = PGServerEnvironment()
    
    var order_ID:String?
    var cust_ID:String?
    
    var orderID = ""
    
    let pincodeArr = ["520001", "520002", "520003", "520004", "520005", "520006", "520007", "520008", "520009", "520010", "520011", "520012", "520013", "520014", "520015", "521104", "521108", "521137"]
    
    private let appInvoke = AIHandler()
    
    
    var reponseStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Place Order"
        // Do any additional setup after loading the view.
        let backBtn = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationController?.addcolorToBar()
        self.navigationItem.leftBarButtonItem = backBtn
        descView.isHidden = true
        gettingDates()
        calculateDiscount()
        self.containerView.addBorderToview()
        dropDown1.layer.borderWidth = 0.5
        dropDown2.layer.borderWidth = 0.5
        choosePaymentBtn.layer.borderWidth = 0.5
        
        addressLab.text = (addressDict["personname"] as! String)
        locationLab.text = (addressDict["address"] as! String)
        print("The json cart data is", jsoncartArr)
        DispatchQueue.main.async {
            self.getOffers()
        }
        var temp : CGFloat = 0
        print("the system height is", self.view.frame.size.height, self.scrollView.frame.size.height)
        if self.view.frame.size.height < 550 {
            temp = 900
        } else {
            temp = 850
        }
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.containerView.frame.size.height)
        print("the system height after change is", self.scrollView.frame.size.height, temp)
        settingNewArray()
        NotificationCenter.default.addObserver(self, selector: #selector(placingOrderAction), name: NSNotification.Name("placingOrderAction"), object: nil)
        
    
    }
    func getOffers() {
        global.api.gettingServerResponse(urlString: global.offers) { (json) in
            print("slide data is ",json)
            if json.count == 0 {
                // self.callingToast()
                return
            }
            let offerArr = json["offers"] as! NSArray
            for i in 0...offerArr.count - 1 {
                let dict = offerArr[i] as! NSDictionary
                print(dict["offerName"] as! String)
                self.offers.append(dict["offerName"] as! String)
            }
        }
    }
    func getPincode() -> Bool{
        let replacedString =    String((self.addressDict["address"] as! String).filter { !" \n\t\r".contains($0) })
        print("the repaced string",replacedString)
        let addressArr = replacedString.components(separatedBy: ",")
        
        print("Address is", addressArr)
        for i in 0...pincodeArr.count - 1 {
            let pinStr = pincodeArr[i]
            print("pincode str and address str is", pinStr, addressArr)
            if addressArr.contains(pinStr) {
                return true
            }
        }
        return false
    }
    func calculateDiscount() {
        //productdiscountprice
        for i in 0...jsoncartArr.count - 1 {
            let dict = jsoncartArr[i]
            print("the dict is",dict)
            let totPrice = dict["productprice"] as! Int
            let discPrice = dict["productdiscountprice"] as! Int
            //productquno
            let productQty = dict["productquno"] as! Int
            totalAmt = totalAmt + (totPrice * productQty)
            discountTotAmt = discountTotAmt + (discPrice * productQty)
            print("the Amounts are",totalAmt,discountTotAmt)
        }
        
    }
    @objc func sideMenuAction() {
        self.navigationController?.dismiss(animated: false, completion:nil)
        self.navigationController?.popViewController(animated: true)
    }
    func gettingDates() {
        //d MMM yyyy
        let df = DateFormatter()
        df.dateFormat = "d MMM yyyy"
        
        for i in 1 ... 5 {
            var tenDaysfromNow: Date {
                return (Calendar.current as NSCalendar).date(byAdding: .day, value: i, to: Date(), options: [])!
            }
            let dateStr = df.string(from: tenDaysfromNow)
            print("The next dae", dateStr)
            dayArray.append(dateStr)
        }
        let timeAttrArr = timeArray.enumerated().map { index, element in
            return NSAttributedString(string: element, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13.0)])
        }
        let dayAttrArr = dayArray.enumerated().map { index, element in
            return NSAttributedString(string: element, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13.0)])
        }
        dayStr = dayAttrArr[0]
        dropDown1.attributedText = dayAttrArr[0]
        dropDown1.optionArray = dayAttrArr
        dropDown2.optionArray = timeAttrArr
        dropDown1.selectedIndex = 0
        dropDown2.text = "Choose TimeSlot"
        dropDown1.didSelect{(selectedText , index ,id) in
            self.dayStr = selectedText
        }
        dropDown2.didSelect{(selectedText , index ,id) in
            self.timeStr = selectedText
            self.descView.isHidden = false
            
            self.settingData()
        }
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
    func settingData() {
        if totalAmt <= 300 {
            deliveryChares = 40
        } else {
            deliveryChares = 0
        }
        if discountTotAmt < 300 {
            SCLAlertView().showInfo("Important info", subTitle: "If Total Amount is greater than RS 300 then delivery charges are free")
        }
        orderItemText.text = String(jsoncartArr.count)
        deliverydateText.attributedText = dayStr
        deliveryTimeText.attributedText = timeStr
        orderCostText.text = String(totalAmt)
        savingCostText.text = String(totalAmt - discountTotAmt)
        deliveryChargeText.text = String(deliveryChares)
        totalAmtText.text = String(discountTotAmt + deliveryChares)
        print("the amounts are",String(totalAmt),String(discountTotAmt))
        print("total amount",String(totalAmt - discountTotAmt))
    }
    //Choose TimeSlot
    @IBAction func deliveryBtnAction(_ sender: Any) {
        
    }
    @IBAction func promoAction(_ sender: Any) {
        print(dayStr)
        print(timeStr)
        print("total Amount", totalAmt)
        print("total discount Amount", discountTotAmt)
        if promoText.text?.count == 0 {
            SCLAlertView().showInfo("Important info", subTitle: "Please Enter promo code")
            return
        }
        let parameter : [String: Any] = ["promocode":promoText.text!]
        ANLoader.showLoading("Checking Offer", disableUI: true)
        global.api.postServerDataandgetResponse(urlString: global.checkOffer, parameters: parameter) { (json) in
            let dict = json["offerDetails"] as! NSDictionary
            print(dict["offerValidupto"]!)
            let validDate = dict["offerValidupto"]! as! String
            let currentDate = Date()
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd-MM-YYYY"
            let dateTime = dateFormat.string(from: currentDate)
            // print(dateTime)
            if validDate < dateTime {
                print("failed")
                self.placeorderLab.text = "Entered Promocode is not valid.Please check again"
            } else {
                if self.totalAmt < 600 {
                    self.placeorderLab.text = "offer valid only for minimum order amount of 300"
                } else {
                    self.placeorderLab.text = ""
                }
                print("valid")
            }
            ANLoader.hide()
        }
    }
    //Choose Paymode
    //Pay on Delivery
    //Pay Now
    @IBAction func choosePayment(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        // alertView.addButton("First Button", target:self, selector:Selector("firstButton"))
        alertView.addButton("Pay on Delivery") {
            self.choosePaymentBtn.setTitle("Pay On Delivery", for: .normal)
            self.payStr = "COD"
        }
        alertView.addButton("Pay Now") {
            self.choosePaymentBtn.setTitle("Pay Now", for: .normal)
            self.payStr = "PAYTM"
        }
        alertView.showSuccess("Choose PayMode", subTitle: "Please Select payment mode")
    }
    @IBAction func radioSelected(_ sender: radioButton) {
        for btn in self.radioBtn {
            btn.radioSelected = (btn == sender) ? true: false
        }
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        if radioBtn[1].radioSelected == true {
            print("Monthly Selected")
            typeStr = "month"
            alertView.addButton("Cancel") {
                print("Second button tapped")
            }
            alertView.addButton("Yes", target:self, selector:#selector(self.addtoCart))
            alertView.showSuccess("Confirmation For Monthly Cart", subTitle: "Do you want to add this items into Monthly Cart?")
        } else {
            
            //  addselctedItemsToCart(cartType: "Monthly")
            typeStr = "week"
            // addtoCart()
            alertView.addButton("Cancel") {
                print("Second button tapped")
            }
            alertView.addButton("Yes", target:self, selector:#selector(self.addtoCart))
            alertView.showSuccess("Confirmation For Weekly Cart", subTitle: "Do you want to add this items into Weekly Cart?")
            //print("Weekly Selected")
        }
    }
    func testCart() {
        let request = NSMutableURLRequest(url: NSURL(string: global.addtoWeeklymonthCart)! as URL)
        request.httpMethod = "POST"
       // let postString = "userid=\(UserDefaults.standard.object(forKey: global.KUserId)!), productData=\(jsoncartArr), cartType=\(typeStr))"
        let parameter : [String : Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!, "productData" : jsoncartArr, "cartType" : typeStr]
      //  request.httpBody = parameter.data(using: String.Encoding.utf8)
        print(parameter)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                print("error=\(String(describing: error))")
                return
            }

            print("response = \(String(describing: response))")

            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    /*{
     "userid": "CACO54818",
     "priceid": "CAPD1195629831",
     "productid": "CAID1052603936",
     "productname": "Lifebuoy Sanitizer",
     "productprice": 250,
     "productdiscountprice": 245,
     "productquantity": "1",
     "productquno": 1,
     "productweight": "500 ML",
     "productimage": "Uploads/Items/011970000000lifebuoy-hand-sanitizer.jpg"
 },*/
    func settingNewArray() {
       // var tempArr = [Dictionary<String,Any>]()
        for dict in jsoncartArr {
            let jsonDict = NSMutableDictionary()
            let userid = dict["userid"]
            let priceid = dict["priceid"]
            let productid = dict["productid"]
            let productname = dict["productname"]
            let productprice = dict["productprice"]
            let productdiscountprice = dict["productdiscountprice"]
            let productquantity = dict["productquantity"]
            let productquno = dict["productquno"]
            let productweight = dict["productweight"]
            let productimage = dict["productimage"]
        

            jsonDict["userid"] = userid
            jsonDict["priceid"] = priceid
            jsonDict["productid"] = productid
            jsonDict["productname"] = productname
            jsonDict["productprice"] = productprice
            jsonDict["productdiscountprice"] = productdiscountprice
            jsonDict["productquantity"] = productquantity
            jsonDict["productquno"] = productquno
            jsonDict["productweight"] = productweight
            jsonDict["productimage"] = productimage
            cartArr.append(jsonDict)
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: cartArr, options: [])
            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                print(jsonString)
                jsonVal = jsonString
        
            }
        } catch {
            print(error)
        }
    }
    
    @objc func addtoCart() {

        let parameter : [String : Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!, "productData" : jsonVal, "cartType" : typeStr]
        print(parameter)
        global.api.postServerDataandgetResponse(urlString: global.addtoWeeklymonthCart, parameters: parameter) { (json) in
            print(json)
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
       }
    }
    
    // you have to generate unique customer ID (Generate random string - less than 50 length count )
    
    
    @IBAction func placeOrderAction(_ sender: Any) {
        if getPincode(){
        if payStr == "" {
            SCLAlertView().showInfo("Important info", subTitle: "Please choose payment option before Place Order")
            return
        }
            //"ACTION" : "generate_Checksum",
        let uuid = UUID().uuidString
        orderID = uuid.replacingOccurrences(of: "-", with: "", options: .regularExpression)
        print(orderID)
        params = ["MID": "GrUFRx39482429291340",//"GrUFRx39482429291340",
                  
                  "ORDER_ID": String(orderID),
                  "CUST_ID": UserDefaults.standard.object(forKey: global.KUserId) as! String,
                  "MOBILE_NO": UserDefaults.standard.object(forKey: global.KMobile) as! String,
                  "EMAIL": UserDefaults.standard.object(forKey: global.KMailId) as! String,
                  "CHANNEL_ID": "WAP",
                  "WEBSITE": "DEFAULT",
                  "TXN_AMOUNT":String(self.discountTotAmt),
                  "INDUSTRY_TYPE_ID": "Retail",
                  "ACTION": "generate_Checksum",
                  "CALLBACK_URL": "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=\(orderID)"
        ]

            
        if payStr == "PAYTM" {
           // PaytmServerCall(params: paramDict)
            PaytmServerCall(params: params)
        } else if payStr == "COD" {
            ANLoader.showLoading("Please Wait...", disableUI: true)
            sendingdatatoserver(transId: "")
        }
        } else {
         //   SCLAlertView().showInfo("Important info", subTitle: "We are presently not providing Cartcorner services to out of Vijayawada City, Please Stay with us we will touch you soon ")
            SCLAlertView().showInfo("Important info", subTitle: "Sorry, We are not delivering in this pincode.Soon we will reach out to you. Tnak you.")
                        return
        }
    }
    
    
    func PaytmServerCall(params:[String:String]){
        print("The checsum json is", params)
        global.api.submitDatatoServer(urlString: global.check_sum, parameters: params as NSDictionary) { (json) in
            print("the checksum reponse is",json as NSDictionary)
            DispatchQueue.main.async { [self] in
                let dict = json as! [String : Any]
                if dict.containsKey("message") {
                    SCLAlertView().showInfo("Important info", subTitle: "Error getting, Please Try again")
                    return
            } else {
                /*Staging Environment: "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=<order_id>"
                 Production Environment: "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=<order_id>"*/
            let checkSumStr = json["txnToken"] as! String
                if json["payt_STATUS"] as! Int  == 1 && checkSumStr.count != 0 {
                    let orderID = params["ORDER_ID"]!
                    
                    self.appInvoke.openPaytm(merchantId: "GrUFRx39482429291340",
                                             orderId: String(orderID),
                                             txnToken: checkSumStr,
                                             amount: String(self.discountTotAmt),
                                             callbackUrl: "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=\(orderID)>",
                                             delegate: self,
                                             environment:.production,
                                             urlScheme: "")
                }
            }
            }
        }
    }
    
    func sendingdatatoserver(transId:String) {
        let param : [String : Any] = ["userid":UserDefaults.standard.object(forKey: global.KUserId)!,
                                      "username":"sri",
                                      "userphone":UserDefaults.standard.object(forKey: global.KMobile)!,
                                      "useremail":UserDefaults.standard.object(forKey: global.KMailId)!,
                                      "deliverydate":dayStr.string,
                                      "deliverytime":timeStr.string,
                                      "totalamount":String(totalAmt),
                                      "deliverycharges":String(deliveryChares),
                                      "discountamount":String(discountTotAmt),
                                      "paymentmethod":"ONLINE",
                                      "carttype":"shop",
                                      "transactionid":transId,
                                      "couponcode":"",
                                      "products":jsonVal,
                                      "deliveryaddress":addressDict["address"] as! String
        ]
        print("the placed order is", param)
        global.api.postServerDataandgetResponse(urlString: global.placeOrder, parameters: param as [String : Any]) { (json) in
            var style = ToastStyle()
            // this is just one of many style options
            style.messageColor = .red
            style.backgroundColor = .lightGray
            ToastManager.shared.isTapToDismissEnabled = true
            if (json.count == 0) {
                DispatchQueue.main.async {
                    self.view.makeToast("payment failed.Please Try Again", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                }
                return
            }
            //self.jsonArr = json["myaddresses"] as! NSArray
            DispatchQueue.main.async {
                ANLoader.hide()
                print("the addressses are",json)
                if json["error"] as! Bool == false {
                    ANLoader.hide()
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let orderVC = storyBoard.instantiateViewController(withIdentifier: "orderConfirm") as! orderSuccessVC
                    self.navigationController?.pushViewController(orderVC, animated: true)
                } else {
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        self.view.makeToast("payment failed.Please Try Again", duration: 3.0, position: .bottom, style: style)
                        // toggle "tap to dismiss" functionality
                    }
                }
            }
        }
    }
    /*The notification details are [AnyHashable("BANKNAME"): WALLET, AnyHashable("RESPMSG"): Txn Success, AnyHashable("TXNAMOUNT"): 1.00, AnyHashable("TXNID"): 20211027111212800110168149357452147, AnyHashable("BANKTXNID"): 170700582851, AnyHashable("PAYMENTMODE"): PPI, AnyHashable("GATEWAYNAME"): WALLET, AnyHashable("ORDERID"): D73DB99FF5E2464AA42D2B1A067D0A71, AnyHashable("RESPCODE"): 01, AnyHashable("STATUS"): TXN_SUCCESS, AnyHashable("CURRENCY"): INR, AnyHashable("CHECKSUMHASH"): FRGVwVzkv5JFtJn9Y6zHlTdkrhVC06RvYovI1pz6U8GTaY4TYHAhlsI3/mwCeRmdbzVrMVb/QrMNriHHuFI4CjfX9BF+V/VbdOIisU5P+R4=, AnyHashable("TXNDATE"): 2021-10-27 11:37:27.0, AnyHashable("MID"): GrUFRx39482429291340]*/
    @objc func placingOrderAction(notification:NSNotification) {
        print("The notification details are", notification.userInfo!)
        let jsonDict = notification.userInfo as! [String:String]
        if jsonDict["STATUS"] != "TXN_SUCCESS" {
            //handle what you want
            print("fail time",jsonDict)
        } else {
            sendingdatatoserver(transId: jsonDict["TXNID"]!)
            print("the success data is",jsonDict)
            
        }
    }
}


extension PlaceOrderVC : UITextFieldDelegate, AIDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        var style = ToastStyle()
        // this is just one of many style options
        style.messageColor = .red
        style.backgroundColor = .lightGray
        ToastManager.shared.isTapToDismissEnabled = true
        let refreshAlert = UIAlertController(title: "Offers", message: "Please Select Offer", preferredStyle: UIAlertController.Style.alert)
        //   let offerArr = ["sri","veera","guru","swamy","venky"]
        if offers.count == 0 {
            DispatchQueue.main.async {
                self.view.makeToast("Currently there are no offers to select", duration: 3.0, position: .bottom, style: style)
                // toggle "tap to dismiss" functionality
            }
        } else {
            
            for str in offers {
                refreshAlert.addAction(UIAlertAction(title: str, style: .default, handler: { (action: UIAlertAction!) in
                    print("Handle Ok logic here")
                    self.promoText.text = str
                }))
            }
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    func openPaymentWebVC(_ controller: UIViewController?) {
        if let vc = controller {
            DispatchQueue.main.async {[weak self] in
             //   self?.present(vc, animated: true, completion: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
      //  self.dismiss(animated: true)
    }
    func didFinish(with status: AIPaymentStatus, response: [String : Any]) {
      //  print("🔶 Paytm Callback Response: ", response)
        if response["STATUS"] as! String != "TXN_SUCCESS" {
            //handle what you want
            print("fail time",response)
           // removeController(controller: self.txnController)
            //  controller.navigationController?.popViewController(animated: true)
        } else {
            sendingdatatoserver(transId: response["TXNID"]! as! String)
            print("the success data is",response)
            // controller.navigationController?.popViewController(animated: true)
        }

       
    }
}
extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
extension Dictionary {

    func containsKey(_ key: Key) -> Bool {
        index(forKey: key) != nil
    }

}
/*userid:CACO16889
 username:Murali
 userphone:7893440959
 useremail:muraliremod7@gmail.com
 deliverydate:""
 deliverytime:""
 totalamount:500
 deliverycharges:0
 discountamount:28
 paymentmethod:ONLINE
 products:""
 carttype:""
 transactionid:""
 couponcode:""*/



//check offer code
/*promocode:GET50*/
/*userid:CACO26087
 priceid:1
 productid:19FK3502
 productname:Annapurna Aata
 productprice:70
 productdiscountprice:68
 productquantity:2
 productquno:2
 productweight:1 KG
 productimage:*/

//https://stackoverflow.com/questions/49147837/how-to-integrate-paytm-payment-gateway-in-swift
/*{
 CHECKSUMHASH = "CATC7reWCNGZJZYA+0N2S4iRuZDHNei1oW/MZV3nQKoxGrc1QNjj/OgfpnmFZR0g5rFQoD07BCmTrXr4aey828lZu1sk7y0fDo3sKOZfmd8=";
 "ORDER_ID" = 6CA190331B714C5A92814DA0E03B7789;
 "payt_STATUS" = 1;
 }*/
/* {
 "error": false,
 "offerDetails": {
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
 }
 }*/
/*{"ORDERID":"10726DE41BE54803B5855BB9877A1329", "MID":"YLTDFD41680125543578", "TXNAMOUNT":"55.00", "CURRENCY":"INR", "STATUS":"TXN_FAILURE", "RESPCODE":"330", "RESPMSG":"Invalid checksum", "BANKTXNID":""}*/
/*{"CURRENCY":"INR", "GATEWAYNAME":"WALLET", "RESPMSG":"Txn Success", "BANKNAME":"WALLET", "PAYMENTMODE":"PPI", "MID":"GrUFRx39482429291340", "RESPCODE":"01", "TXNID":"20201018111212800110168300753860747", "TXNAMOUNT":"1.00", "ORDERID":"076114F3A6A644D88378CBD03F162CDB", "STATUS":"TXN_SUCCESS", "BANKTXNID":"146365806233", "TXNDATE":"2020-10-18 18:25:20.0", "CHECKSUMHASH":"e300jj1gipAeLL+8QAaYYzoQz2uBkdcGz/YjVfxolSeflySQbe6Mm7gxIN3ArkYQpjMldU/D7zrG0tvkim8K2SSyL0G7atzpWJh8LU5ABbg="}*/
/*extension PlaceOrderVC : PGTransactionDelegate {
    func errorMisssingParameter(_ controller: PGTransactionViewController, error: NSError?) {
        print(error!.localizedDescription)
        controller.navigationController?.popViewController(animated: true)
    }
    
    func didSucceedTransaction(controller: PGTransactionViewController, response: [NSObject : AnyObject]) {
        print("didSucceedTransaction",response)
    }
    func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
        //  print("the response string is",responseString) // Response will be in string
        do{
            if let json = responseString.data(using: String.Encoding.utf8){
                if let jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:String]{
                    if jsonData["STATUS"] != "TXN_SUCCESS" {
                        //handle what you want
                        print("fail time",jsonData)
                        removeController(controller: self.txnController)
                        //  controller.navigationController?.popViewController(animated: true)
                    } else {
                        sendingdatatoserver(transId: jsonData["TXNID"]!)
                        print("the success data is",jsonData)
                        // controller.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }catch {
            print(error.localizedDescription)
            
        }
    }
    func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        print(error!)
        controller.navigationController?.popViewController(animated: true)
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController) {
        print("User camcelled the trasaction")
        controller.navigationController?.popViewController(animated: true)
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        self.removeController(controller: controller)
        print(error!)
    }
    
    func sendingdatatoserver(transId:String) {
        let param : [String : Any] = ["userid":UserDefaults.standard.object(forKey: global.KUserId)!,
                                      "username":"sri",
                                      "userphone":UserDefaults.standard.object(forKey: global.KMobile)!,
                                      "useremail":UserDefaults.standard.object(forKey: global.KMailId)!,
                                      "deliverydate":dayStr.string,
                                      "deliverytime":timeStr.string,
                                      "totalamount":String(totalAmt),
                                      "deliverycharges":String(deliveryChares),
                                      "discountamount":String(discountTotAmt),
                                      "paymentmethod":"ONLINE",
                                      "carttype":"shop",
                                      "transactionid":transId,
                                      "couponcode":"",
                                      "products":jsonVal,
                                      "deliveryaddress":addressDict["address"] as! String
        ]
        print("the placed order is", param)
        global.api.postServerDataandgetResponse(urlString: global.placeOrder, parameters: param as [String : Any]) { (json) in
            var style = ToastStyle()
            // this is just one of many style options
            style.messageColor = .red
            style.backgroundColor = .lightGray
            ToastManager.shared.isTapToDismissEnabled = true
            if (json.count == 0) {
                DispatchQueue.main.async {
                    self.view.makeToast("payment failed.Please Try Again", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                }
                return
            }
            //self.jsonArr = json["myaddresses"] as! NSArray
            DispatchQueue.main.async {
                ANLoader.hide()
                print("the addressses are",json)
                if json["error"] as! Bool == false {
                    ANLoader.hide()
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let orderVC = storyBoard.instantiateViewController(withIdentifier: "orderConfirm") as! orderSuccessVC
                    self.navigationController?.pushViewController(orderVC, animated: true)
                } else {
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        self.view.makeToast("payment failed.Please Try Again", duration: 3.0, position: .bottom, style: style)
                        // toggle "tap to dismiss" functionality
                    }
                }
            }
        }
        
    }
    /*{
     "error": false,
     "message": "Order Placed successfully"
     }*/
}*/
/*  func showController(controller: PGTransactionViewController) {
    
    if self.navigationController != nil {
        self.navigationController?.pushViewController(controller, animated: true)
    } else {
        self.present(controller, animated: true, completion: nil)
    }
}

func removeController(controller: PGTransactionViewController) {
    
    if self.navigationController != nil {
        self.navigationController?.popViewController(animated: true)
    } else {
        controller.dismiss(animated: true, completion: nil)
    }
}
func placingOrdertoServer(){
    
}*/


/*     // let order = PGOrder(orderID: "", customerID: "", amount: "", eMail: "", mobile: "")
 // print(checkSumStr)
/*    let order = PGOrder()
 //Test id -    YLTDFD41680125543578 - YLTDFD41680125543578
 //Server id  - GrUFRx39482429291340
 //self.totalAmt
 order.params =
     ["MID": "YLTDFD41680125543578",
      "ORDER_ID": orderID,
      "CUST_ID": UserDefaults.standard.object(forKey: global.KUserId) as! String,
      "MOBILE_NO": UserDefaults.standard.object(forKey: global.KMobile) as! String,
      "EMAIL": UserDefaults.standard.object(forKey: global.KMailId) as! String,
      "CHANNEL_ID": "WAP",
      "WEBSITE": "DEFAULT",
      "TXN_AMOUNT": "1",//String(self.discountTotAmt),
      "INDUSTRY_TYPE_ID": "Retail",
      "CHECKSUMHASH": checkSumStr,
      "CALLBACK_URL": "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=\(orderID)"]
 print(order.params)
 self.txnController =  self.txnController.initTransaction(for: order) as! PGTransactionViewController
 self.txnController.title = "Paytm Payments"
 self.txnController.setLoggingEnabled(true)
 if(type != ServerType.eServerTypeNone) {
     self.txnController.serverType = type;
 } else {
     return
 }
 self.txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
 self.txnController.delegate = self
 self.showController(controller: self.txnController)*/*/

/*{"error":false,"CHECKSUMHASH":"uYnSqEKB0+kpsq+rBTYO76a8VCbX5xB4VwMiDgnKB9TiwIkUA58S171HixpwmgRQegEOh40n4AHGoofbq9eJmyBMoVisVefQWb3evTk2nok=","ORDER_ID":"138636C626D148C9BF03708F0995CE10","payt_STATUS":1}*/
/*Staging Environment: "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=<order_id>"
 Production Environment: "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=<order_id>"*/


/*Paytm Callback Response:  paytmGrUFRx39482429291340://payment?orderId=0642655C6EB54953ABB63AA3C0776227&mid=GrUFRx39482429291340&txnToken=801254b35bc14a9f929c1bf7580f089e1635145567546&status=PYTM_103&response={"BANKTXNID":"170500320872","GATEWAYNAME":"WALLET","TXNID":"20211025111212800110168376756475937","MID":"GrUFRx39482429291340","TXNAMOUNT":"1.00","BANKNAME":"WALLET","RESPMSG":"Txn Success","CURRENCY":"INR","PAYMENTMODE":"PPI","ORDERID":"0642655C6EB54953ABB63AA3C0776227","TXNDATE":"2021-10-25 12:36:07.0","CHECKSUMHASH":"T6APf6jffVocAWYmNehjmAhEkqqLZaLQ\/+kwV0gAhj9SgMzO7Y3l2TXnM98oBczxrv27Bphs4JGwABg+de0yVSnK0LPxUvO3pSV3ru76tj4=","STATUS":"TXN_SUCCESS","RESPCODE":"01"}*/
