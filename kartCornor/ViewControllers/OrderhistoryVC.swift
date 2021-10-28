//
//  OrderhistoryVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Alamofire

class OrderhistoryVC: UIViewController {
    
    @IBOutlet weak var historyTable: UITableView!
    
    var jsonArr = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        // Do any additional setup after loading the view.
        let backBarButon = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "burger")
        self.navigationItem.leftBarButtonItem = backBarButon
        self.title = "Order History"
        getOrderdatafromServer()
        historyTable.tableFooterView = UIView()
    }
    func getOrderdatafromServer() {
        ANLoader.showLoading("Fetching Order details", disableUI: true)
        let userId = UserDefaults.standard.object(forKey: global.KUserId)!
        let parameter : [String: Any] = ["userid" : userId]
        print("h parameter", parameter)
        global.api.postServerDataandgetResponse(urlString: global.orderHistory, parameters: parameter) { (json) in
            if (json.count == 0) {
                self.perform(#selector(self.sideMenuAction), with: nil, afterDelay: 4.0)
                DispatchQueue.main.async {
                    var style = ToastStyle()
                    style.messageColor = .red
                    style.backgroundColor = .lightGray
                    self.view.makeToast("data not found.Please Try Again", duration: 3.0, position: .bottom, style: style)
                    // toggle "tap to dismiss" functionality
                    ToastManager.shared.isTapToDismissEnabled = true
                }
                return
            }
            
            var sampleArr = json["orders"] as! [NSDictionary]
            
          //  let sortedArray = (sampleArr as NSArray).sortedArray(using: [NSSortDescriptor(key: "deliverydate", ascending: true)]) as! [NSDictionary]
            
            sampleArr.sort { (firstItem, secondItem) -> Bool in
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "dd MMM yyyy"

             if let dateAString = firstItem["deliverydate"] as? String,
                 let dateBString = secondItem["deliverydate"] as? String,
                 let dateA = dateFormatter.date(from: dateAString),
                 let dateB = dateFormatter.date(from: dateBString){
                 return dateA.compare(dateB) == .orderedDescending
             }
             return false
            }
            self.jsonArr = sampleArr
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                print("the History is are",jsonArr)
                self.historyTable.reloadData()
            }
        }
    }
    @objc func sideMenuAction() {
        sideMenuManager?.toggleSideMenuView()
    }
}
extension OrderhistoryVC : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderHistoryCell
        let dict = jsonArr[indexPath.row]
        cell.orderIDLab.text = (dict["orderid"] as! String)
        cell.dateLabel.text = (dict["deliverydate"] as! String)
        cell.timeLabel.text = (dict["deliverytime"] as! String)
        cell.amountLabel.text = String(describing: dict["totalamount"]!)
        cell.discountLabel.text = String(describing: dict["discountamount"]!)
        cell.statusLabel.text = (dict["orderstatus"] as! String)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : detailHistoryVC = storyboard.instantiateViewController(withIdentifier: "detailHistory") as! detailHistoryVC
        
        itemView.jsonDict = jsonArr[indexPath.row]
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}
/*userid:CACO26087*/
/*{
 "orders": [
 {
 "orderid": "CACO59165",
 "deliverydate": "24 Aug 2020",
 "deliverytime": "9AM - 2PM",
 "totalamount": 224,
 "deliverycharges": 40,
 "discountamount": 2,
 "orderstatus": "Processing",
 "paymentmethod": "COD",
 "products": "[{\"priceid\":\"CAPD63577846\",\"productdisprice\":\"184\",\"productid\":\"CAID1762094505\",\"productimage\":\"http://cartcorner.in/cartcornerAdmin/Uploads/Items/011970000000\",\"productname\":\"Lizol Surface Cleaner Lavender\",\"productprice\":\"186\",\"productquantity\":\"1\",\"productquno\":\"2\",\"productweight\":\"500 ML\"}]"
 },
 {
 "orderid": "CACO18006",
 "deliverydate": "24 Aug 2020",
 "deliverytime": "9AM - 2PM",
 "totalamount": 918,
 "deliverycharges": 0,
 "discountamount": 2,
 "orderstatus": "Order Placed",
 "paymentmethod": "COD",
 "products": "[{\"priceid\":\"CAPD753451855\",\"productdisprice\":\"918\",\"productid\":\"CAID453480900\",\"productimage\":\"http://cartcorner.in/cartcornerAdmin/Uploads/Items/011970000000\",\"productname\":\"Ariel Matic Liquid Detergent\",\"productprice\":\"920\",\"productquantity\":\"1\",\"productquno\":\"2\",\"productweight\":\"2 LTRS\"}]"
 }
 ]
 }*/
