//
//  detailHistoryVC.swift
//  kartCornor
//
//  Created by Srinivas on 26/09/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke
import SwiftyJSON

class detailHistoryVC: UIViewController {
    
    var jsonDict : NSDictionary = NSDictionary()
    var json = [[String: Any]]()
    @IBOutlet weak var historyTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        self.title = "Order History"
        // Do any additional setup after loading the view.
        let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBarButon
        
        guard let gUnwrap = jsonDict["products"] else{return}
        
        let jsonString = (gUnwrap as! String)

        let data = (jsonString.data(using: .utf8))!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options :.allowFragments) as? [Dictionary<String,Any>]
            {
                print("the json array is", jsonArray)
                json = jsonArray
            } else if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSArray {
                print("array json", json)
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print("the errrrr ",error)
        }
    }
    @objc func sideMenuAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension detailHistoryVC : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return json.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! HistoryDescCell
        let dict = json[indexPath.row]
        let formatter = NumberFormatter()
        cell.titleLab.text = (dict["productname"] as! String)
        cell.quantityLab.text = (dict["productquantity"] as! String) + "*" +  (dict["productweight"] as! String)
        let string2 = formatter.string(from: dict["productprice"] as! NSNumber)
       // let prodStr = dict["productprice"] as! String
       // cell.priceLab.text = "\u{20B9}" + prodStr
        cell.priceLab.text = "\u{20B9}" + string2!
      //  let imgStr = (dict["productimage"]  as! String)
        var imgStr = ""
        if (dict["productimage"]  as! String).contains(global.imgUrl) {
            imgStr = (dict["productimage"]  as! String)
        } else {
            imgStr = global.imgUrl + (dict["productimage"]  as! String)
        }
        let url = URL(string: imgStr)
        if url == nil {
            cell.imgView.image = UIImage(named: "noimage.jpg")
        } else {
            Nuke.loadImage(with: url!, into: cell.imgView)
        }
        return cell
    }
}
extension String {
    
    func removingAllWhitespaces() -> String {
        return removingCharacters(from: .whitespaces)
    }
    
    func removingCharacters(from set: CharacterSet) -> String {
        var newString = self
        newString.removeAll { char -> Bool in
            guard let scalar = char.unicodeScalars.first else { return false }
            return set.contains(scalar)
        }
        return newString
    }
}
/*{
 "orderid": "CACO59165",
 "deliverydate": "24 Aug 2020",
 "deliverytime": "9AM - 2PM",
 "totalamount": 224,
 "deliverycharges": 40,
 "discountamount": 2,
 "orderstatus": "Processing",
 "paymentmethod": "COD",
 "products": "[{\"priceid\":\"CAPD63577846\",\"productdisprice\":\"184\",\"productid\":\"CAID1762094505\",\"productimage\":\"http://cartcorner.in/cartcornerAdmin/Uploads/Items/011970000000\",\"productname\":\"Lizol Surface Cleaner Lavender\",\"productprice\":\"186\",\"productquantity\":\"1\",\"productquno\":\"2\",\"productweight\":\"500 ML\"}]"
 }*/
/*{"cartitems":[{"userid":"CACO54818","priceid":"CAPD1587715182","productid":"CAID1158190769","productname":"SoftTouchOceanBreezePerfume","productprice":55,"productdiscountprice":54,"productquantity":"1","productquno":2,"productweight":"250ML","productimage":"Uploads/Admin/011970000000softtouch-ocean-breeze.jpg"}]}*/
/*// print("The json dict object is", neStr)
 do{
 if let json = neStr.data(using: String.Encoding.utf8){
 if let jsonData = try JSONSerialization.jsonObject(with: json, options: []) as? [[String:AnyObject]]{
 print("the o/p is", jsonData)
 }
 }
 }catch {
 print("the new error is",error.localizedDescription)
 
 }
 
 
 
 
 //print("The single object is", neStr)
 let jConfigs = JSON(neStr).array
 if let data = neStr.data(using: .utf8) {
 if let json = try? JSON(data: data) {
 for item in json.arrayValue {
 print("the items are",item["priceid"].stringValue)
 }
 }
 }
 */
