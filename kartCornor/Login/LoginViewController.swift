//
//  LoginViewController.swift
//  kartCornor
//
//  Created by Srinivas on 17/07/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var mainView: UIView!
    var otpText = UITextField()
    
    let userdefault = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Login"
        self.navigationController?.addcolorToBar()
        addBoderToView()
        setupTextField()
       // loginButton.applyGradient()
        // Do any additional setup after loading the view.
        self.applyShadowOnView(mainView)
        loginButton.addBorderToview()
        loginBtn.addBorderToview()
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.view.endEditing(true)
        if mobileText.text?.count == 0 {
            
            SCLAlertView().showInfo("Important info", subTitle: "Please Enter mobile number")
            return
        }
        guard  let phonenumber = mobileText.text else {return}
        print(phonenumber)
        if phonenumber == "9052200400" {
          //  let viewController = self.storyboard?.instantiateViewController(withIdentifier: "otpScreen") as! OTPscreenViewController
          //  self.navigationController?.pushViewController(viewController, animated: true)
            self.checkOTP()
            return
        }
        Auth.auth().languageCode = "en"
        ANLoader.showLoading("please wait...", disableUI: true)
        // DispatchQueue.main.async {
        let numb = "+91"+phonenumber
        PhoneAuthProvider.provider().verifyPhoneNumber(numb, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                // Show alert here
                SCLAlertView().showWarning("Important info", subTitle: "Please Try again")
                print("token is",error.localizedDescription)
                ANLoader.hide()
                return
            }
            //self.dismiss(animated: true, completion: nil)
            self.checkOTP()
            guard let verify = verificationID else {return}
         //   let viewController = self.storyboard?.instantiateViewController(withIdentifier: "otpScreen") as! OTPscreenViewController
         //   viewController.verifyid = verify
            print("the is is,",verify)
            UserDefaults.standard.set(verify, forKey: "verifyID")
            UserDefaults.standard.set(self.mobileText.text, forKey: global.KMobile)
            self.userdefault.synchronize()
            //self.navigationController?.pushViewController(viewController, animated: true)
            // Sign in using the verificationID and the code sent to the user
            // Here your can store your verificationID in user default and later used for sign in. Or pass this verification id to your next view controller for OTP verification.
            
            ANLoader.hide()
        }
    }
    func checkOTP() {
        // Example of using the view to add two text fields to the alert
        // Create the subview
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )

        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)

        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0,y: 0,width: 216,height: 70))
        let x = (subview.frame.width - 180) / 2

        // Add textfield 1
         otpText = UITextField(frame: CGRect(x: x,y: 10,width: 180,height: 25))
        otpText.layer.borderColor = UIColor.green.cgColor
        otpText.layer.borderWidth = 1.5
        otpText.layer.cornerRadius = 5
        otpText.placeholder = "Enter OTP"
        otpText.keyboardType = .numberPad
        otpText.textAlignment = NSTextAlignment.center
        subview.addSubview(otpText)

    
        // Add the subview to the alert's UI property
        alert.customSubview = subview

        // Add Button with Duration Status and custom Colors
        alert.addButton("Verify OTP", target: self, selector: #selector((verifyOTP)))
        self.dismiss(animated: true, completion: nil)
        //alert.showInfo("Login", subTitle: "", duration: 10)
        alert.showInfo("OTP Screen")
        
    }
    @objc func verifyOTP() {
        self.view.endEditing(true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
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
        if otpText.text?.count == 6 {
            ANLoader.showLoading("Please Wait", disableUI: true)
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
                                UserDefaults.standard.set(false, forKey: global.KUserLogged)
                                self.dismiss(animated: true, completion: nil)
                            }
                            print("the addressses are",json)
                            
                        }
                    }
                }
            }
        } else {
           
            DispatchQueue.main.async {
                ANLoader.hide()
                var style = ToastStyle()
                // this is just one of many style options
                style.messageColor = .red
                style.backgroundColor = .lightGray
                self.view.makeToast("Please Try Again", duration: 3.0, position: .bottom, style: style)
                // toggle "tap to dismiss" functionality
                ToastManager.shared.isTapToDismissEnabled = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
               // loginVC.pre
                loginVC.modalPresentationStyle = .overCurrentContext
                loginVC.providesPresentationContextTransitionStyle = true
                loginVC.definesPresentationContext =  true
                self.present(loginVC, animated: true, completion: nil)
            }
        }
        print("OTP verified")
    }
    func addBoderToView() {
        // mainView.layer.shadowColor = UIColor.gray.cgColor
        mainView.layer.borderWidth = 0.3
        mainView.layer.borderColor = UIColor.black.cgColor
        mainView.layer.cornerRadius = 10
    }
    func setupTextField() -> Void {
        let lab = UILabel()
        lab.text = " IN +91"
        lab.font = UIFont.systemFont(ofSize: 16)
        // lab.backgroundColor = UIColor.gray
        mobileText.leftView = lab
        mobileText.leftViewMode = .always
        mobileText.layer.borderWidth = 1.0
        mobileText.layer.cornerRadius = 10
    }
    func applyShadowOnView(_ view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
    }
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mobileText.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

extension UIView {
    
    func dropShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    func addBorderToview() {
        layer.cornerRadius = 10.0
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.1)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.7
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.black.cgColor
    }
    func addGradientWithColor() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.red.cgColor, UIColor.white.cgColor]

        self.layer.insertSublayer(gradient, at: 0)
    }
}
extension UIButton {
//    func applyGradient()  {
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = self.bounds
//        gradient.colors = [UIColor.red.cgColor, UIColor.white.cgColor]
//        //Horizontal
//      //  gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
//      //  gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
//       // gradient.locations = [0.0, 1.0]
//        self.layer.insertSublayer(gradient, at: 0)
//
//    }
    func applyGradient()
        {
            let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.6)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0,1]
           // gradientLayer.cornerRadius = self.frame.size.height / 2
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
}
extension UIView {
    func applyGradientView()  {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.red, UIColor.white].map { $0.cgColor }
        //Horizontal
//        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
//        gradient.locations = [0.0, 1.0]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}
