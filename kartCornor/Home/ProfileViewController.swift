    //
    //  ProfileViewController.swift
    //  kartCornor
    //
    //  Created by Srinivas on 17/07/20.
    //  Copyright © 2020 Srinivas. All rights reserved.
    //
    
    import UIKit
    
    class ProfileViewController: UIViewController {
        
        @IBOutlet weak var profileTable: UITableView!
        let personalArray = ["Name","Email ID","Mobile Number","Address"];
        let addressArray = ["Your Address","Landmark","Pincode"];
        var finalArr = [String]()
        var jsonDict = [String:Any]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.addcolorToBar()
           // self.navigationController?.navigationBar.topItem?.title = "User Profile"
            self.title = "Profile"
            gettingProfileData()
            profileTable.tableFooterView = UIView()
            let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "burger")
                   self.navigationItem.leftBarButtonItem = backBarButon
        }
        @objc func sideMenuAction() {
            sideMenuManager?.toggleSideMenuView()
        }
        func gettingProfileData() {
            let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!]
            ANLoader.showLoading("Please Wait", disableUI: true)
            global.api.postServerDataandgetResponse(urlString: global.userProfile, parameters: parameter) { (json) in
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
                self.jsonDict = json["userdata"] as! [String:Any]
                DispatchQueue.main.async { [unowned self] in
                    ANLoader.hide()
                    print("profile data",json)
//                    let addressArr = (self.jsonDict["userdefaultaddress"] as! String).components(separatedBy: ", ")
//                    let addressStr = addressArr[0] + "," + addressArr[1] + "," + addressArr[2] + "," + addressArr[3] + "," + addressArr[4]
//                    let landMarkStr = addressArr[5]
//                    let pincodeStr = addressArr[6]
//                    self.finalArr.append(addressStr)
//                    self.finalArr.append(landMarkStr)
//                    self.finalArr.append(pincodeStr)
                    self.profileTable.reloadData()
                }
            }
        }
        //editProfile
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation*/
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "editProfile" {
                let editProfileVC = segue.destination as! EditProfileView
                editProfileVC.jsonDict = jsonDict
            }
        }
    }
    
    extension ProfileViewController : UITableViewDataSource,UITableViewDelegate {
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1;
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if jsonDict.count > 0 {
                return 4
            }
            return 0
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell : ProfileCell = profileTable.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
            cell.headLabel.text = personalArray[indexPath.row];
            
                if (indexPath.row == 0){
                    cell.detailLabel.text = (jsonDict["username"] as! String)
                } else if (indexPath.row == 1){
                    cell.detailLabel.text = (jsonDict["usermail"] as! String)
                } else if (indexPath.row == 2){
                    cell.detailLabel.text = (jsonDict["userphone"] as! String)
                } else if (indexPath.row == 3){
                    cell.detailLabel.text = (jsonDict["userdefaultaddress"] as! String)
                }
            
            return cell;
        }
        // UITableViewAutomaticDimension calculates height of label contents/text
           func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
               // Swift 4.2 onwards
               return UITableView.automaticDimension
           }
    }

    /*userid:CACO26087*/
    /*{
     "userdata": {
     "username": "Srinivas ",
     "usermail": "srinivasp6110@gmail.com",
     "userphone": "9052200400",
     "userdefaultaddress": "1, small, rajamundry, Jampeta, by, danviapeta, 56467",
     "userprofilepic": ""
     }
     }*/
