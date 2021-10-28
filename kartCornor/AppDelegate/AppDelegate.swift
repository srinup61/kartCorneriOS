//
//  AppDelegate.swift
//  kartCornor
//
//  Created by Srinivas on 17/07/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseInstanceID
import FirebaseMessaging
import AppInvokeSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    var window: UIWindow?
    
    var isReachable = Bool()
    
    var reachability: Reachability?
    let hostNames = [nil, "google.com", "invalidhost"]
    var hostIndex = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        Messaging.messaging().delegate = self
        registerForPushNotifications()
        loginCheck()
        return true
    }
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        loginCheck()
        return true
    }
    /*{
        "username": "chi",
        "usermail": "srinu@gmail.com",
        "userphone": "9052200400",
        "secureid": "53VUddE4IoN6IGh0YoydtH2tdnb2",
        "userid": "CACO54818",
        "userCity": "duh",
        "inserted": "1"
    }*/
    func loginCheck() {
//        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
//            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
//        } else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
//            let nav = UINavigationController(rootViewController: loginVC)
//            self.window?.rootViewController = nav
//        }
        
        
      
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                //   print("Permission granted: \(granted)")
                guard granted else { return }
                self!.getNotificationSettings()
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            //  print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        Messaging.messaging().apnsToken = deviceToken
        
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        })
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
       // let dict = separateDeeplinkParamsIn(url: url.absoluteString, byRemovingParams: nil)
        print("The url is", url)
        
        if let responseStr = url.absoluteString.removingPercentEncoding {
            
           print("The test pupose string", responseStr)

            let test1 = url.valueOf("response")!
            
            print("the json string is", test1)
            let data = test1.data(using: .utf8)!
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
                {
                   print(jsonArray) // use the json here
                    NotificationCenter.default.post(name: Notification.Name("placingOrderAction"), object: nil, userInfo: jsonArray)
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        return true
    }
    
}
extension UINavigationBar {
    func setGradientBackground(colors: [Any]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.locations = [0.0 , 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)

        var updatedFrame = self.bounds
        updatedFrame.size.height += self.frame.origin.y
        gradient.frame = updatedFrame
        gradient.colors = colors;
        self.setBackgroundImage(self.image(fromLayer: gradient), for: .default)
    }

    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage!
    }
}
extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
