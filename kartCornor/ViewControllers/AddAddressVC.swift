//
//  AddAddressVC.swift
//  kartCornor
//
//  Created by Srinivas on 13/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class AddAddressVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var nicknameText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var housenoText: UITextField!
    @IBOutlet weak var streetText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var areaText: UITextField!
    @IBOutlet weak var apartmentText: UITextField!
    @IBOutlet weak var landmarkText: UITextField!
    @IBOutlet weak var pincodeText: UITextField!
    
    
    @IBOutlet weak var checkBox: Checkbox!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveAddress: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        self.navigationController?.navigationBar.topItem?.title = "Add Address"
        self.title = "Add Address"
        let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBarButon
        // Do any additional setup after loading the view.
        //        nicknameText.useUnderline()
        //        nameText.useUnderline()
        //        housenoText.useUnderline()
        //        streetText.useUnderline()
        //        cityText.useUnderline()
        //        areaText.useUnderline()
        //        apartmentText.useUnderline()
        //        landmarkText.useUnderline()
        //        pincodeText.useUnderline()
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 650)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        //  self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveAction(_ sender: UIButton) {
        if (nameText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Name")
            return
        } else if (nicknameText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Nick name")
            return
        } else if (housenoText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter House no")
            return
        } else if (streetText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Street")
            return
        } else if (cityText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter City")
            return
        } else if (areaText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Area")
            return
        }
//        else if (apartmentText.text?.count == 0) {
//            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Apartment name")
//            return
//        }
        else if (landmarkText.text?.count == 0) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Landmark")
            return
        } else if (pincodeText.text?.count != 6) {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Valid pincode")
            return
        } else {
            gettingAddress()
        }
    }
    
    func gettingAddress() {
        // guard let id = categoryDict["categoryid"] else {return}
        // let userId = "CACO26087"
        let addressStr = "\(housenoText.text! as NSString), \(streetText.text! as NSString), \(cityText.text! as NSString), \(areaText.text! as NSString), \(apartmentText.text! as NSString), \(landmarkText.text! as NSString), \(pincodeText.text! as NSString)"
        // let addressStr = housenoText.text? + streetText.text? + cityText.text? + areaText.text? + apartmentText.text?
        var defaultType = "0"
        if checkBox.isChecked {
            defaultType = "1"
        } else {
            defaultType = "0"
        }
        let parameter : [String: Any] =
            ["userid":UserDefaults.standard.object(forKey: global.KUserId)!,
             "address":addressStr,
             "personname":nameText.text!,
             "addressnickname":nicknameText.text!,
             "latlong":"",
             "defaulttype": defaultType]
        print(parameter)
        ANLoader.showLoading("Please Wait", disableUI: true)
        global.api.postServerDataandgetResponse(urlString: global.addAddress, parameters: parameter) { (json) in
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
                self.dismiss(animated: true, completion: nil)
                //self.navigationController?.popToRootViewController(animated: true)
                print("the addressses are",json)
            }
        }
    }
}

/*userid:
 defaulttype:
 address:
 addressnickname:
 personname:
 latlong:*/
