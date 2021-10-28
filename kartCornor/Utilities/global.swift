//
//  global.swift
//  kartCornor
//
//  Created by Srinivas on 10/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import Foundation
import UIKit

struct global {
    
    static let userDef = UserDefaults.standard
    //getlowerslides
    static let imagePath = "http://cartcorner.in"
    
    static let lowerSlides = "http://cartcorner.in/cartApi/Api.php?apicall=getlowerslides"
    static let slideUrl = "http://cartcorner.in/cartApi/Api.php?apicall=getslides"
    static let allCategories = "http://cartcorner.in/cartApi/Api.php?apicall=getcategories"
    static let subcategories = "http://cartcorner.in/cartApi/Api.php?apicall=getsubcategories"
    
    static let brandnames = "http://cartcorner.in/cartApi/Api.php?apicall=getbradnames"
    static let getProducts = "http://cartcorner.in/cartApi/Api.php?apicall=getproducts"
    static let productById = "http://cartcorner.in/cartApi/Api.php?apicall=getproductbyid"
    static let brandProducts = "http://cartcorner.in/cartApi/Api.php?apicall=getbrandproducts"
    static let allProducts = "http://cartcorner.in/cartApi/Api.php?apicall=getAllproducts"
    
    
    static let cartItems = "http://cartcorner.in/cartApi/Api.php?apicall=getcartitems"
    static let weekCart = "http://cartcorner.in/cartApi/Api.php?apicall=getweekcartitems"
    static let monthCart = "http://cartcorner.in/cartApi/Api.php?apicall=getmonthcartitems"
    static let updateCart = "http://cartcorner.in/cartApi/Api.php?apicall=updateacartitem"
    static let deleteCartItem = "http://cartcorner.in/cartApi/Api.php?apicall=deletecartitem"
    
    static let addtoCart = "http://cartcorner.in/cartApi/Api.php?apicall=addproducttocart"
    static let addtoMonthlyCart = "http://cartcorner.in/cartApi/Api.php?apicall=addproducttomonthlycart"
    static let addtoWeeklymonthCart = "http://cartcorner.in/cartApi/Api.php?apicall=addproducttoweekmonthcart"
    
    static let defaultAddress = "http://cartcorner.in/cartApi/Api.php?apicall=setdefaultaddress"
    static let addAddress = "http://cartcorner.in/cartApi/Api.php?apicall=addaddress"
    static let getAddress = "http://cartcorner.in/cartApi/Api.php?apicall=getaddresses"
    static let updateaddress = "http://cartcorner.in/cartApi/Api.php?apicall=updateaddress"
    
    static let userProfile = "http://cartcorner.in/cartApi/Api.php?apicall=userprofile"
    static let verifyProfile = "http://cartcorner.in/cartApi/Api.php?apicall=verifyprofile"
    static let userLogin = "http://cartcorner.in/cartApi/Api.php?apicall=signup1"
    static let updateProfile = "http://cartcorner.in/cartApi/Api.php?apicall=profileupdatewithimage"
    
    static let offers = "http://cartcorner.in/cartApi/Api.php?apicall=getoffers"
    static let checkOffer = "http://cartcorner.in/cartApi/Api.php?apicall=checkoffercode"
    
    static let walletAmount = "http://cartcorner.in/cartApi/Api.php?apicall=getwalletamount"
    static let addwalletAmount = "http://cartcorner.in/cartApi/Api.php?apicall=addamounttowallet"
    static let clearWallet = "http://cartcorner.in/cartApi/Api.php?apicall=clearwalletamount"
    
    static let placeOrder = "http://cartcorner.in/cartApi/Api.php?apicall=placeorder"
    static let orderHistory = "http://cartcorner.in/cartApi/Api.php?apicall=getorders"
    
    static let check_sum = "http://cartcorner.in/cartApi/generateChecksum.php"
    
    static let imgUrl = "http://cartcorner.in/cartcornerAdmin/"
    //  static let isReachable = NetworkManager.sharedInstance
    static let api = Network.sharedInstance
   
    
    static let KMobile = "mobileNumber"
    static let KMailId = "mailid"
    static let KUserId = "userID"
    static let KFireBaseID = "firebaseID"
    static let KUserLogged = "loggedin"
    
    
    
}
extension UITextField {
    
    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(0.6)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
