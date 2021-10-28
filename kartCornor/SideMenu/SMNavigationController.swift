//
//  SMNavigationController.swift
//  LNSideMenuEffect
//
//  Created by Luan Nguyen on 6/30/16.
//  Copyright © 2016 Luan Nguyen. All rights reserved.
//

import LNSideMenu

class SMNavigationController: LNSideMenuNavigationController {
    
    fileprivate var items:[String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Using default side menu
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
            items = ["Home","User Profile","Shopping Cart","Monthly Cart","Weekly Cart","Order History","Cancel And return Policy","Terms and Conditions","About Us","Contact Us","Rate Us","Share","Logout"]
        } else {
            items = ["Home","Cancel And return Policy","Terms and Conditions","About Us","Contact Us","Rate Us","Share","Log-In"]
        }
        
        //    initialSideMenu(.left)
        // Custom side menu
        initialCustomMenu(pos: .left)
    }
    
    fileprivate func initialSideMenu(_ position: Position) {
        menu = LNSideMenu(sourceView: view, menuPosition: .left, items: items!)
        // menu?.menuViewController?.menuBgColor = UIColor.black.withAlphaComponent(0.85)
        menu?.menuViewController?.menuBgColor = UIColor.init(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.4)
        menu?.delegate = self
        menu?.underNavigationBar = true
        view.bringSubviewToFront(navigationBar)
    }
    
    fileprivate func initialCustomMenu(pos position: Position) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuTableViewController") as! LeftMenuTableViewController
        vc.delegate = self
        menu = LNSideMenu(navigation: self, menuPosition: .left, customSideMenu: vc, size: .custom(UIScreen.main.bounds.width - 120))
        menu?.delegate = self
        menu?.enableDynamic = true
        // Moving down the menu view under navigation bar
        //    menu?.underNavigationBar = true
    }
    
    fileprivate func setContentVC(_ index: Int) {
        print("Did select item at index: \(index)")
        var nViewController: UIViewController? = nil
        //        if let viewController = viewControllers.first , viewController is HomeViewController {
        //            nViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")
        //        } else {
        //            nViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
        //        }
        //
        if   UserDefaults.standard.bool(forKey: global.KUserLogged) {
            UserDefaults.standard.set(true, forKey: "sidemenu")
            UserDefaults.standard.synchronize()
            switch index {
            case 0:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            case 1:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")
            case 2:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "cartVC")
            case 3:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "monthlyVC")
            case 4:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "weeklyVC")
            case 5:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "addressVC")
            case 6:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "historyVC")
            case 7:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "policyVC")
            case 8:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "termsVC")
            case 9:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "aboutVC")
            case 10:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "contactVC")
            case 11:
                return
            case 12:
                shareApp()
            default:
                loggedout()
            //  nViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            }
        } else {
            switch index {
            case 0:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            case 1:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "policyVC")
            case 2:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "termsVC")
            case 3:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "aboutVC")
            case 4:
                nViewController = storyboard?.instantiateViewController(withIdentifier: "contactVC")
            case 5:
                return
            case 6:
                shareApp()
            default:
                loggedin()
            //  nViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
            }
        }
        
        if let viewController = nViewController {
            self.setContentViewController(viewController)
        }
        // Test moving up/down the menu view
        if let sm = menu, sm.isCustomMenu {
            menu?.underNavigationBar = false
        }
    }
}

extension SMNavigationController: LNSideMenuDelegate {
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    
    func didSelectItemAtIndex(_ index: Int) {
        setContentVC(index)
    }
    func shareApp() {
        let someText:String = "Hey, Could you please try this app to get grocessries to your door"
        if let urlStr = NSURL(string: "https://apps.apple.com/us/app/cart-corner/id1532923180") {
            let objectsToShare = [someText ,urlStr] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popup = activityVC.popoverPresentationController {
                    popup.sourceView = self.view
                    popup.sourceRect = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0)
                }
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    func loggedout() {
        UserDefaults.standard.set(false, forKey: global.KUserLogged)
        UserDefaults.standard.set("", forKey: global.KMobile)
        UserDefaults.standard.set("", forKey: global.KMailId)
        UserDefaults.standard.synchronize()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! SMNavigationController
        appDelegate.window?.rootViewController = loginVC
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
}

extension SMNavigationController: LeftMenuDelegate {
    func didSelectItemAtIndex(index idx: Int) {
        menu?.toggleMenu() { [unowned self] in
            self.setContentVC(idx)
        }
    }
}

