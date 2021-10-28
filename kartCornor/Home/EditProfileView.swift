//
//  EditProfileView.swift
//  kartCornor
//
//  Created by Srinivas on 31/07/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileView: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var imageTake: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var browseBtn: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var mailText: UITextField!
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    var imagePicker: UIImagePickerController!
    
    var jsonDict = [String:Any]()
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    /*{
     "username": "Srinivas ",
     "usermail": "srinivasp6110@gmail.com",
     "userphone": "9052200400",
     "userdefaultaddress": "1, small, rajamundry, Jampeta, by, danviapeta, 56467",
     "userprofilepic": ""
     }*/
    /* ["1-24", "main road", "Amalapuram", "East godavari", "swmay", "side road", "534213"]*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // print(jsonDict)
        self.navigationController?.addcolorToBar()
        self.title = "Edit Profile"
        // Do any additional setup after loading the view.
        let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBarButon
        mobileText.text = (jsonDict["userphone"] as! String)
        mailText.text = (jsonDict["usermail"] as! String)
        nameText.text = (jsonDict["username"] as! String)
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameText.resignFirstResponder()
        mailText.resignFirstResponder()
    }
    @IBAction func updateAction(_ sender: Any) {
        if nameText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Name")
            return
        } else if mobileText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Mobile number")
            return
        } else if mailText.text?.count == 0 {
            SCLAlertView().showWarning("Important info", subTitle: "Please Enter Email-id")
            return
        } else if imageTake.image == nil {
            SCLAlertView().showWarning("Important info", subTitle: "Please select picture")
            return
        } else {
           updateProfile()
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
       // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    func messageAlert() {
        
    }
    
    @IBAction func browseAction(_ sender: Any) {
        
        print("image add")
       self.view.endEditing(true)
        let alert = UIAlertController(title: nil, message: "Choose your source", preferredStyle: UIAlertController.Style.alert)

         alert.addAction(UIAlertAction(title: "Camera", style: .default) { (result : UIAlertAction) -> Void in
           print("Camera selected")
         //  self.imagePicker.sourceType = .camera
          // self.present(self.imagePicker, animated: true, completion: nil)
            self.selectImageFrom(.camera)
         })
         alert.addAction(UIAlertAction(title: "Photo library", style: .default) { (result : UIAlertAction) -> Void in
           print("Photo selected")
        //   self.imagePicker.sourceType = .photoLibrary
         //  self.present(self.imagePicker, animated: true, completion: nil)
            self.selectImageFrom(.photoLibrary)
         })

         self.present(alert, animated: true, completion: nil)
    }
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
    }
    func updateProfile(){
        //Set Your URL
        let api_url = global.updateProfile
        guard let url = URL(string: api_url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "POST"
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //Set Your Parameter
        let parameterDict = NSMutableDictionary()
        parameterDict.setValue(UserDefaults.standard.object(forKey: global.KUserId)!, forKey: "userid")
        parameterDict.setValue(mailText.text, forKey: "usermail")
        parameterDict.setValue(mobileText.text, forKey: "userphone")
        parameterDict.setValue(nameText.text, forKey: "username")
        
        print(parameterDict)
        
        //Set Image Data
        let imgData = self.imageTake.image!.jpegData(compressionQuality: 0.10)!
        
        // Now Execute
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in parameterDict {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key as! String + "[]"
                        if let string = element as? String {
                            multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                            if let num = element as? Int {
                                let value = "\(num)"
                                multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
            }
            multiPart.append(imgData, withName: "userprofilepic", fileName: "file.png", mimeType: "image/png")
        }, with: urlRequest)
            .uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON(completionHandler: { data in
                ANLoader.hide()
                switch data.result {
                    
                case .success(_):
                    do {
                        
                        let dictionary = try JSONSerialization.jsonObject(with: data.data!, options: .fragmentsAllowed) as! NSDictionary
                        
                        print("Success!")
                        print(dictionary)
                        self.navigationController?.popViewController(animated: true)
                    }
                    catch {
                        // catch error.
                        print("catch error")
                        
                    }
                    break
                    
                case .failure(_):
                    print("failure")
                    SCLAlertView().showWarning("Important info", subTitle: "Profile updation failed.Please Try Again")
                    break
                    
                }
                
                
            })
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
}
/*
 userprofilepic
 usermail
 userphone
 username
 userid
 */
