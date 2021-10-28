    //
    //  editAddressVC.swift
    //  kartCornor
    //
    //  Created by Srinivas on 17/08/20.
    //  Copyright © 2020 Srinivas. All rights reserved.
    //
    
    import UIKit
    
    class editAddressVC: UIViewController {
        var addressDict = NSDictionary()
        @IBOutlet weak var mainView: UIView!{
            didSet {
                mainView.layer.cornerRadius = 10.0
                mainView.layer.shadowColor = UIColor.gray.cgColor
                mainView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                mainView.layer.shadowRadius = 6.0
                mainView.layer.shadowOpacity = 0.7
                mainView.layer.borderWidth = 0.3
                mainView.layer.borderColor = UIColor.black.cgColor
            }
        }
        
        @IBOutlet weak var pincodeText: UITextField!
        @IBOutlet weak var nameText: UITextField!
        @IBOutlet weak var nickText: UITextField!
        @IBOutlet weak var descText: UITextView! {
            didSet {
                descText.layer.cornerRadius = 10.0
                descText.layer.shadowColor = UIColor.gray.cgColor
                descText.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                descText.layer.shadowRadius = 6.0
                descText.layer.shadowOpacity = 0.7
                descText.layer.borderWidth = 0.3
                descText.layer.borderColor = UIColor.black.cgColor
            }
        }
        @IBOutlet weak var cancelBtn: UIButton!
        @IBOutlet weak var updateBtn: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.addcolorToBar()
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.title = "Edit Address"
            // Do any additional setup after loading the view.
            print(addressDict)
            nameText.text = (addressDict["personname"] as! String)
            nickText.text = (addressDict["addressnickname"] as! String)
            descText.text = (addressDict["address"] as! String)
        }
        
        @IBAction func cancelAction(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
          //  self.dismiss(animated: true, completion: nil)
        }
        @IBAction func updateAction(_ sender: Any) {
            if (nameText.text?.count == 0){
                alertMessage(msgStr: "Please enter your name")
            } else if (nickText.text?.count == 0){
                alertMessage(msgStr: "please enter your nick name")
            } else if (descText.text?.count == 0){
                alertMessage(msgStr: "please update your address")
            } else if (pincodeText.text?.count == 0 || pincodeText.text!.count < 6){
                alertMessage(msgStr: "Please enter valid pincode")
            } else {
                gettingAddress()
            }
        }
        func gettingAddress() {
            let addressId = addressDict["addressid"]
            let addStr = descText.text + "," + pincodeText.text!
            let parameter : [String: Any] =
                ["userid":UserDefaults.standard.object(forKey: global.KUserId)!,
                 "addressid" : addressId!,
                 "address":addStr,
                 "personname":nameText.text!,
                 "addressnickname":nickText.text!]
            print(parameter)
            ANLoader.showLoading("Please Wait", disableUI: true)
            global.api.postServerDataandgetResponse(urlString: global.updateaddress, parameters: parameter) { (json) in
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
              //  self.jsonArr = json["myaddresses"] as! NSArray
                DispatchQueue.main.async { [unowned self] in
                    ANLoader.hide()
                    self.navigationController?.popViewController(animated: true)
                    print("the addressses are",json)
                }
            }
        }
        func alertMessage(msgStr : String) {
            SCLAlertView().showInfo("Important info", subTitle: msgStr)
        }
    }
    /*addressid:
     address:
     personname:
     addressnickname:*/
