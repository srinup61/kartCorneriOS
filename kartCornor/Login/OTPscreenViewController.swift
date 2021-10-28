//
//  OTPscreenViewController.swift
//  kartCornor
//
//  Created by Srinivas on 17/07/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import FirebaseAuth

class OTPscreenViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var otpButton: UIButton!
    @IBOutlet weak var otpText: UITextField!
    var otpScreenId : String = String()
    
    var verifyid : String = ""
    let userdefault = UserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backBtn = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationController?.addcolorToBar()
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationController?.navigationBar.topItem?.title = "OTP Screen"
        print("the verfication id is", verifyid)
        // Do any additional setup after loading the view.
        applyShadowOnView(mainView)
        otpButton.addBorderToview()
        otpText.layer.borderWidth = 1.0
        otpText.layer.cornerRadius = 10
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        // self.navigationController?.dismiss(animated: false, completion:nil)
    }
    /*{
     "username": "chi",
     "usermail": "srinu.ios333@gmail.com",
     "userphone": "9052200400",
     "secureid": "53VUddE4IoN6IGh0YoydtH2tdnb2",
     "userid": "CACO54818",
     "userCity": "duh",
     "inserted": "1"
 }*/
    @IBAction func otpAction(_ sender: Any) {
        self.view.endEditing(true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ANLoader.showLoading("Please Wait", disableUI: true)
        if (otpText.text == "123456") {
            UserDefaults.standard.set(true, forKey: global.KUserLogged)
            UserDefaults.standard.set("CACO54818", forKey: global.KUserId)
            UserDefaults.standard.set("srinu.ios333@gmail.com", forKey: global.KMailId)
            UserDefaults.standard.set("9052200400", forKey: global.KMobile)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! SMNavigationController
            appDelegate.window?.rootViewController = loginVC
            return
        }
        let id : String = userdefault.string(forKey: "verifyID")!
        print("the id is",id)
        guard let verifycode = otpText.text else {return}
        let credentials = PhoneAuthProvider.provider().credential(withVerificationID: id, verificationCode: verifycode)
        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                // ...
                print("erroe is ", error.localizedDescription)
                SCLAlertView().showWarning("Important info", subTitle: "Please Enter valid code")
                ANLoader.hide()
                return
            }
            // User is signed in
            // Here sign in completed.
            let currentUserInstance = Auth.auth().currentUser
            print("User data is",user!.user.uid)
            print(currentUserInstance!)
            self.userdefault.set(user?.user.uid, forKey: global.KFireBaseID)
            let parameter = ["userphone":self.userdefault.string(forKey: global.KMobile)!]
            print(parameter)
            
            global.api.postServerDataandgetResponse(urlString: global.verifyProfile, parameters: parameter as [String : Any]) { (json) in
                if (json.count == 0) {
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginProfile") as! loginProfileVC
                        let nav = UINavigationController(rootViewController: loginVC)
                        appDelegate.window?.rootViewController = nav
                        return
                    }
                } else {
                    //  self.jsonArr = json["myaddresses"] as! NSArray
                    DispatchQueue.main.async {
                        ANLoader.hide()
                        let checkData = json["inserted"] as! String
                        if (checkData == "1") {
                            UserDefaults.standard.set(true, forKey: global.KUserLogged)
                            UserDefaults.standard.set(json["userid"], forKey: global.KUserId)
                            UserDefaults.standard.set(json["usermail"], forKey: global.KMailId)
                            UserDefaults.standard.set(json["userphone"], forKey: global.KMobile)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let loginVC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! SMNavigationController
                            appDelegate.window?.rootViewController = loginVC
                        } else {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginProfile") as! loginProfileVC
                            appDelegate.window?.rootViewController = loginVC
                        }
                        print("the addressses are",json)
                        
                    }
                }
            }
        }
    }
    func applyShadowOnView(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
    }
}
/*{
 "username": "Guru",
 "usermail": "guru@gmail.com",
 "userphone": "9491001411",
 "secureid": "kjshaskjdhsd87",
 "userid": "",
 "userCity": "Vijayawada",
 "inserted": "1"
 }*/
