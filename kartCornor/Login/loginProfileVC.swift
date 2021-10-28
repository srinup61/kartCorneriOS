//
//  loginProfileVC.swift
//  kartCornor
//
//  Created by Srinivas on 27/09/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

class loginProfileVC: UIViewController {
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mailText: UITextField!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var pincodeText: UITextField!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var addressView: UITextView!
    @IBOutlet weak var landmarkText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        mainView.addBorderToview()
        self.title = "User Profile"
        mobileText.text = (UserDefaults.standard.object(forKey: global.KMobile) as! String)
        // Do any additional setup after loading the view.
        updateBtn.layer.borderWidth = 0.5
        updateBtn.layer.cornerRadius = 10
    }
    
    @IBAction func updateProfileAction(_ sender: Any) {
        if nameText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Name")
            return
        } else if mailText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Mail-id")
            return
        } else if pincodeText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Pincode")
            return
        } else if landmarkText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Landmark")
            return
        } else if addressView.text.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Adddress")
            return
        } else {
            updateDetails()
        }
        
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    func updateDetails() {
        if !isValidEmail(mailText.text ?? "") {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter valid Email")
            return
        }
        ANLoader.showLoading("Please wait...", disableUI: true)
        let parameter : NSDictionary = [
            "username":nameText.text!,
            "userphone":(UserDefaults.standard.object(forKey: global.KMobile) as! String),
            "usermail":mailText.text!,
            "userdefaultaddress":addressView.text!,
            "city":landmarkText.text!,
            "latlong":pincodeText.text!,
            "secureid":(UserDefaults.standard.object(forKey: global.KFireBaseID) as! String),
            "firebasetoken":"",
            "password":""
        ]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        global.api.postServerDataandgetResponse(urlString: global.userLogin, parameters: parameter as! [String : Any]) { (json) in
            
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
            DispatchQueue.main.async {
                ANLoader.hide()
                print("The signup data is",json)
                if json["error"] as! Bool == false {
                    UserDefaults.standard.set(true, forKey: global.KUserLogged)
                    UserDefaults.standard.set(json["userid"] as! String, forKey: global.KUserId)
                    UserDefaults.standard.set(json["phone"] as! String, forKey: global.KMobile)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! SMNavigationController
                    appDelegate.window?.rootViewController = loginVC
                } else {
                    SCLAlertView().showWarning("Important info", subTitle: (json["message"] as! String))
                }
            }
        }
    }
}
/*userid:
 username:Guru
 userphone:9491001411
 usermail:guru@gmail.com
 userdefaultaddress:Vijayawada
 city:Vijayawada
 latlong:kjasdhasjkdh
 secureid:kjshaskjdhsd87
 firebasetoken:hsajkdhskjdhsajkdhlsa8732
 password:*/
/*{
    "error": false,
    "message": "User registered successfully",
    "userid": "CACO42739",
    "phone": "9996543210"
}*/
/*{
    error = 1;
    message = "Email Already Registered";
}*/
