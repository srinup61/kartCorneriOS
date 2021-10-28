//
//  constants.swift
//  kartCornor
//
//  Created by Srinivas on 06/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit

let KAppDelegate = UIApplication.shared.delegate as! AppDelegate
class constants: NSObject {
    
  
    static let sharedInstance = constants()

    private override init() {
        
    }

   /* func openSettingApp() {
        DispatchQueue.main.async  {
            KAppDelegate.window?.rootViewController?.showAlertControllerWithStyle(alertStyle: .alert,   title: "Connection Problem", message: "You internet connection is not Ok",  customActions: [ "Cancel", "Setting" ]) { (selectedButton) in
                if selectedButton == 1 {
                    let url:URL = URL(string: UIApplicationOpenSettingsURLString)!
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: {
                            (success) in })
                    } else {
                        guard UIApplication.shared.openURL(url) else {
                            self.displayStatusAlert(message: "Please check your Internet Connection", state: .error)
                            return
                        }
                    }
                }
            }
        }
    }*/
}
