//
//  LeftMenuTableViewController.swift
//  LNSideMenu
//
//  Created by Luan Nguyen on 10/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

protocol LeftMenuDelegate: class {
  func didSelectItemAtIndex(index idx: Int)
}


class LeftMenuTableViewController: UIViewController {
  
  // MARK: IBOutlets
  @IBOutlet weak var menuTableView: UITableView!
  
  // MARK: Properties
  let kCellIdentifier = "menuCell"
    fileprivate var items = [String]()
    fileprivate var imgArray = [String]()
   
  weak var delegate: LeftMenuDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        items = ["Home","User Profile","Shopping Cart","Monthly Cart","Weekly Cart","My Addreses", "Order History","Cancel And return Policy","Terms and Conditions","About Us","Contact Us","Rate Us","Share","Logout"]
         
          imgArray = ["home","address","shop","month","week","address","myorders","home","terms","about","contact","share","whatsapp","signout"]
    } else {
        items = ["Home","Cancel And return Policy","Terms and Conditions","About Us","Contact Us","Rate Us","Share","Log-In"]
         
          imgArray = ["home","home","terms","about","contact","share","whatsapp","login"]
    }
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
   let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
    menuTableView.register(nib, forCellReuseIdentifier: kCellIdentifier)
    self.menuTableView.reloadData()
   
  }
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
//    menuTableView.reloadSections(IndexSet(integer: 0), with: .none)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    menuTableView.backgroundColor = UIColor.init(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.4)
  }
}

extension LeftMenuTableViewController: UITableViewDataSource {
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! MenuTableViewCell
    cell.titleLabel.text = items[indexPath.row]
    cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
    let img = UIImage(named: imgArray[indexPath.row])
    cell.imgView.image = img?.maskWithColor(color: .black)
    return cell
  }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 200))
        headerView.backgroundColor = UIColor.red
        let userAvatarImg = UIImageView.init(frame: CGRect(x: 20, y: 10, width: 90, height: 90))
        // Circle avatar imageview
        userAvatarImg.layer.cornerRadius = userAvatarImg.frame.size.width/2
        userAvatarImg.layer.masksToBounds = true
        userAvatarImg.clipsToBounds = true
        
        // Border
        userAvatarImg.layer.borderWidth = 1
        userAvatarImg.layer.borderColor = UIColor.black.cgColor
        
        // Shadow img
        userAvatarImg.layer.shadowColor = UIColor.white.cgColor
        userAvatarImg.layer.shadowOpacity = 1
        userAvatarImg.layer.shadowOffset = .zero
        userAvatarImg.layer.shadowRadius = 10
        userAvatarImg.layer.shadowPath = UIBezierPath(rect: userAvatarImg.bounds).cgPath
        userAvatarImg.layer.shouldRasterize = true
        userAvatarImg.image = UIImage(named: "profile")
        headerView.addSubview(userAvatarImg)
        let mobileLab = UILabel.init(frame: CGRect(x: 10, y: 110, width: headerView.frame.size.width, height: 30))
        headerView.addSubview(mobileLab)
        if UserDefaults.standard.object(forKey: global.KMobile) == nil {
            mobileLab.text = ""
        } else {
           mobileLab.text = (UserDefaults.standard.object(forKey: global.KMobile) as! String)
        }
        mobileLab.font = UIFont.init(name: "Helvetica Bold", size: 13.0)
        let mailLab = UILabel.init(frame: CGRect(x: 10, y: 135, width: headerView.frame.size.width, height: 30))
        if UserDefaults.standard.object(forKey: global.KMailId) == nil {
            mailLab.text = ""
        } else {
        mailLab.text = (UserDefaults.standard.object(forKey: global.KMailId) as! String)
        }
        mailLab.font = UIFont.init(name: "Helvetica Bold", size: 15.0)
        mailLab.textColor = UIColor.white
        mobileLab.textColor = UIColor.white
        headerView.addSubview(mailLab)
        
        let logoutbtn = UIButton()
        logoutbtn.frame = CGRect(x: 30, y: 170, width: 70, height: 25)
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        logoutbtn.setTitle("Logout", for: .normal)
            logoutbtn.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        } else {
          //  logoutbtn.setTitle("Log-In", for: .normal)
          //  logoutbtn.addTarget(self, action: #selector(self.loginButton), for: .touchUpInside)
        }
        logoutbtn.titleLabel?.font = UIFont(name: "Helvetica", size: 15.0)
        logoutbtn.setTitleColor(UIColor.black, for: .normal)
        
        headerView.addSubview(logoutbtn)
        return headerView
    }
    @objc func buttonTapped(sender : UIButton) {
        //Write button action here
        UserDefaults.standard.set(false, forKey: global.KUserLogged)
        UserDefaults.standard.set("", forKey: global.KMobile)
        UserDefaults.standard.set("", forKey: global.KMailId)
        UserDefaults.standard.synchronize()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! SMNavigationController
        appDelegate.window?.rootViewController = loginVC
    }
    @objc func loginButton(sender : UIButton) {
        if   UserDefaults.standard.bool(forKey: global.KUserLogged) {
            return
        } else {
            sideMenuManager?.hideSideMenuView()
            self.dismiss(animated: true, completion: nil)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            // loginVC.pre
            loginVC.modalPresentationStyle = .overCurrentContext
            loginVC.providesPresentationContextTransitionStyle = true
            loginVC.definesPresentationContext =  true
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}

extension LeftMenuTableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let delegate = delegate {
      delegate.didSelectItemAtIndex(index: indexPath.row)
    }
  }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
}
extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }

}
