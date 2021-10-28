//
//  ItemsViewController.swift
//  kartCornor
//
//  Created by Srinivas on 07/08/20.
//  Copyright © 2020 Srinivas. All righcxts reserved.
//

import UIKit
import Nuke


class ItemsViewController: UIViewController, ModernSearchBarDelegate {
    
    
    var tagView1_data = [[String:Any]]()
    var itemDict : NSDictionary = NSDictionary()
    var itemArray = NSArray()
    var priceData  = NSAttributedString()
    var jsonDict = [Dictionary<String,Any>]()
    var priceID : Int = Int()
    @IBOutlet weak var itemTable: UITableView!
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    var allProducts = [[String : Any]]()
    var itemDesc = NSDictionary()
    var suggestionArray = Array<String>()
    var itemName  = ""
    let serialQueue = DispatchQueue(label: "queuename")
    var tagData = [String]()
    
    var _selectedIndexPath : IndexPath? = nil
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.addcolorToBar()
        itemTable.tableFooterView = UIView()
        collectionView.layer.borderWidth = 2.0
        collectionView.layer.borderColor = UIColor.gray.cgColor
        collectionView.layer.cornerRadius = 10
        collectionView.allowsMultipleSelection = false
        self.title = itemName
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16)!]
        
        self.modernSearchBar.delegateModernSearchBar = self
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        let cartBtn = UIBarButtonItem.menuButton(self, action: #selector(cartView), imageName: "shop")
        self.navigationItem.rightBarButtonItem = cartBtn
        let badgeCount = UserDefaults.standard.string(forKey: "badgeData")
        if badgeCount == "0" || badgeCount?.isEmpty ?? true{
            cartBtn.removeBadge()
        } else {
            cartBtn.addBadge(text: badgeCount!)
        }
        } else {
            let monthCart = UIBarButtonItem.menuButton(self, action: #selector(loginView), imageName: "login")
            self.navigationItem.rightBarButtonItems = [monthCart]
        }
        let backBtn = UIBarButtonItem.menuButton(self, action: #selector(sideMenuAction), imageName: "back")
        self.navigationItem.leftBarButtonItem = backBtn
        // Do any additional setup after loading the view.
        guard let catId = itemDict["categoryid"] else {
            return
        }
        guard let subcatId = itemDict["subcategoryid"] else {
            return
        }
        let firstDict = ["categoryid":catId,"subcategoryid":subcatId,"brandname":"ALL","selected":false,"brandid": "0"]
        tagView1_data.append(firstDict)
        // tagView1_data.
        // print("tagged data in view did load",self.tagView1_data)
        let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId]
        ANLoader.showLoading("Please Wait", disableUI: true)
        serialQueue.sync {
            global.api.postServerDataandgetResponse(urlString: global.getProducts, parameters: parameter) { (json) in
                if (json.count < 1) {
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
                self.itemArray = json["products"] as! NSArray
                DispatchQueue.main.async { [unowned self] in
                    self.tagViewCustomization()
                    self.itemTable.reloadData()
                }
            }
        }
        self.modernSearchBar.makingSearchBarAwesome()
        self.suggestionArray = UserDefaults.standard.object(forKey: "searchArray") as! Array<String>
        self.allProducts = UserDefaults.standard.object(forKey: "allProducts") as! [[String : Any]]
        self.modernSearchBar.setDatas(datas: self.suggestionArray)
        
        
    }
    @objc func cartView() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : ShoppingCartVC = storyboard.instantiateViewController(withIdentifier: "cartVC") as! ShoppingCartVC
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        // self.navigationController?.dismiss(animated: false, completion:nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        // tagView.dataSource = self
    }
    override func didReceiveMemoryWarning() {
        print("Memory issue")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemDescriptionVC" {
            let cell = sender as! UITableViewCell
            if let indexPath = self.itemTable.indexPath(for: cell) {
                let controller = segue.destination as! itemDescriptionVC
                let dict = itemArray[indexPath.row] as! NSDictionary
                controller.itemDict = dict
                controller.titleStr = dict["productname"] as! String
            }
        }
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
    ///Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: "+item)
        for i in 0...allProducts.count - 1 {
            let dict : [String : Any] = allProducts[i]
            print("matching are", dict["productname"]!)
            let prodStr = dict["productname"] as! String
                if prodStr.lowercased() == item.lowercased() {
                print("searched item is",dict)
                itemDesc = dict as NSDictionary
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let itemView : SearchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! SearchVC
                itemView.itemDict = itemDesc
                let nav = UINavigationController(rootViewController: itemView)
                self.present(nav, animated: true, completion: nil)
                return
            }
        }
        // print(op)
    }
    ///Called when user touched shadowView
    func onClickShadowView(shadowView: UIView) {
        print("User touched shadowView")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text did change, what i'm suppose to do ?")
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        for i in 0...allProducts.count - 1 {
            let dict : [String : Any] = allProducts[i]
            let prodStr = dict["productname"] as! String
            if prodStr.contains(searchBar.text!.lowercased())  {
                print(dict)
                itemDesc = dict as NSDictionary
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let itemView : SearchVC = storyboard.instantiateViewController(withIdentifier: "searchVC") as! SearchVC
                itemView.itemDict = itemDesc
                let nav = UINavigationController(rootViewController: itemView)
                self.present(nav, animated: true, completion: nil)
                return
            }
        }
    }
    func tagViewCustomization() {
        guard let catId = itemDict["categoryid"] else {
            return
        }
        guard let subcatId = itemDict["subcategoryid"] else {
            return
        }
        let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId]
        global.api.postServerDataandgetResponse(urlString: global.brandnames, parameters: parameter) { (json) in
            if (json.count < 1) {
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
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                let arr = json["brands"] as! NSArray
                for i in 0...arr.count - 1 {
                    var dict = arr[i] as! [String:Any]
                    dict["selected"] = false
                    self.tagView1_data.append(dict)
                    //  self.tagData.append(dict["brandname"] as! String)
                }
                collectionView.reloadData()
            }
        }
        
    }
}

extension ItemsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! itemTableViewCell
        let dict = itemArray[indexPath.row] as! NSDictionary
        var imgStr = ""
        if (dict["productimage"]  as! String).contains(global.imgUrl) {
            imgStr = (dict["productimage"]  as! String)
        } else {
            imgStr = global.imgUrl + (dict["productimage"]  as! String)
        }
        let url = URL(string: imgStr)
        if url == nil {
            cell.itemImage.image = UIImage(named: "noimage.jpg")
        } else {
            Nuke.loadImage(with: url!, into: cell.itemImage)
        }
        let brandName = dict["productname"] as! String
        cell.titleLabel.text = brandName
        cell.detailTextLabel?.isHidden = false
        cell.countLabel.tag = (indexPath.section * 10) + indexPath.row
        cell.stepper.tag = (indexPath.section*10)+indexPath.row
        cell.cartButton.tag = (indexPath.section*10)+indexPath.row
        cell.stepper.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
       // cell.cartButton.applyGradient()
        cell.cartButton.addTarget(self, action: #selector(cartButtonAction(_:)), for: .touchUpInside)
        //cell.cartButton.addBorderToview()
        
        let data = (dict["productprice"] as! String).data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                let priceArray = makeProductPriceArray(jsondict: jsonArray)
                //   print("the price array is",priceArray)
                if priceArray.count == 0 {
                    cell.dropDownMenu.optionArray = priceArray
                    cell.dropDownMenu.text = "Out of Stock"
                } else {
                    cell.dropDownMenu.optionArray = priceArray
                    cell.dropDownMenu.attributedText = priceArray[0]
                }
                jsonDict = jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        // The the Closure returns Selected Index and String
        cell.dropDownMenu.didSelect{(selectedText , index ,id) in
            self.priceData = selectedText
            self.priceID = index
            cell.countLabel.text = "1"
        }
        //  print(dict)
        return cell
    }
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    @objc  func valueChanged(_ step :UIStepper) {
        //  print("The values are", step.value)
        let section = step.tag / 100
        let row = step.tag % 100
        let indexPath = NSIndexPath(row: row, section: section)
        //  print(indexPath.row)
        let cell = itemTable.cellForRow(at: indexPath as IndexPath) as! itemTableViewCell
        cell.countLabel.text = Int(step.value).description
    }
    
    func makeProductPriceArray(jsondict : [Dictionary<String,Any>]) -> [NSAttributedString] {
        var priceArr = [NSAttributedString]()
        for finalDict in jsondict {
            let priceStr =  String(describing: finalDict["productWeight"]!)
            let discPrice = String(describing: finalDict["productDPrice"]!)
            let origPrice = String(describing: finalDict["productPrice"]!)
            
            // let attributeString = strikeOnLabel(priceStr: origPrice as NSString)
            
            //  print("the striked value is ", attributeString)
            let orgPrice = "\u{20B9}" + origPrice
            let discountPrice = "\u{20B9}" + discPrice
            
            let resultStr = "\(priceStr) , \(orgPrice) , \(discountPrice)"
            // print("caling dump data",getAttributedStrings(text: resultStr))
            priceArr.append(getAttributedStrings(text: resultStr))
        }
        return priceArr
    }
    
    func getAttributedStrings(text: String) -> NSAttributedString {
        
        let words:[String] = text.components(separatedBy: " , ")
        
        var attribWords = [NSAttributedString]()
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)]
        
        let attr = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    NSAttributedString.Key.strikethroughColor: UIColor.black,
                    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)] as [NSAttributedString.Key : Any]
        // print(" words count is ",words)
        for i in 0...words.count - 1 {
            var tempStr = NSAttributedString()
            if i == 1 {
                tempStr = NSAttributedString(string: words[i], attributes: attr)
            } else {
                tempStr = NSAttributedString(string: words[i], attributes: attributes)
            }
            attribWords.append(tempStr)
        }
        //  print("attrib words",attribWords)
        let attribString = NSMutableAttributedString()
        for i in 0 ... attribWords.count - 1 {
            attribString.append(NSAttributedString(string: "  "))
            attribString.append(attribWords[i])
        }
        //        attribWords.forEach{
        //            attribString.append(NSAttributedString(string: " , "))
        //            attribString.append($0)
        //        }
        // let string = attribWords.joined(separator: ",")
        
        //        let attribWords = words.map({
        //            return NSAttributedString(string: " \($0) ", attributes: attributes)
        //        })
        return attribString
    }
    @objc func loginView() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
         loginVC.modalPresentationStyle = .overCurrentContext
         loginVC.providesPresentationContextTransitionStyle = true
         loginVC.definesPresentationContext =  true
         self.present(loginVC, animated: true, completion: nil)
     }
    @objc func cartButtonAction(_ btn:UIButton) {
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        let section = btn.tag / 100
        let row = btn.tag % 100
        let indexPath = NSIndexPath(row: row, section: section)
        // print(indexPath.row)
        let cell = itemTable.cellForRow(at: indexPath as IndexPath) as! itemTableViewCell
        print(cell.countLabel.text!)
        
        let dict = itemArray[indexPath.row] as! NSDictionary
        //  var priceDict = NSDictionary()
        //   DispatchQueue.main.async { [unowned self] in
        // write your code here
        let data = (dict["productprice"] as! String).data(using: .utf8)!
        do {
            if let priceArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                let priceDict = priceArray[0]
                ANLoader.showLoading("Adding to cart", disableUI: true)
                
                let parameter : [String: Any] = ["userid" : UserDefaults.standard.object(forKey: global.KUserId)!,
                                                 "priceid":priceDict["priceId"]!,
                                                 "productid":dict["productid"]!,
                                                 "productname":dict["productname"]!,
                                                 "productprice":priceDict["productPrice"]!,
                                                 "productdiscountprice":priceDict["productDPrice"]!,
                                                 "productquantity":priceDict["productQuantity"]!,
                                                 "productweight":priceDict["productWeight"]!,
                                                 "productimage":dict["productimage"]!,
                                                 "productquno":cell.countLabel.text!]
                print(parameter)
                global.api.postServerDataandgetResponse(urlString: global.addtoCart, parameters: parameter) { (json) in
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
                    if json["error"] as! Int == 1 {
                        DispatchQueue.main.async { [unowned self] in
                            ANLoader.hide()
                            self.view.makeToast("Failed to add Cart", duration: 3.0, title: "", completion: nil)
                            print("Response data",json)
                        }
                    } else {
                        DispatchQueue.main.async { [unowned self] in
                            ANLoader.hide()
                            self.view.makeToast("Added to Cart", duration: 3.0, title: "", completion: nil)
                            print("Response data",json)
                        }
                    }
                }
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        } else {
            self.loggedin()
        }
    }
}
extension ItemsViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagView1_data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath)
            as! tagCollectionCell
        //cell.mainView.addBorderToview()
        cell.layer.cornerRadius = 10
        if _selectedIndexPath == indexPath{
            
            //If the cell is selected
            cell.contentView.layer.borderWidth = 2.0
            cell.tagLabel.textColor = UIColor.black
            cell.tagLabel.backgroundColor = UIColor.gray
        }
        else{
            // If the cell is not selected
            cell.contentView.layer.borderWidth = 0.5
            cell.tagLabel.textColor = UIColor.black
            cell.tagLabel.backgroundColor = UIColor.white
        }
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        let dict = tagView1_data[indexPath.row]
        print("The tagged items are in cell", tagView1_data)
        // dict["selected"] = false
        cell.tagLabel.text = (dict["brandname"] as! String)
        return cell
    }
    /*func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     print("The tagged items are", tagView1_data)
     let cell = collectionView.cellForItem(at: indexPath) as! tagCollectionCell
     
     let updateDict = tagView1_data[indexPath.row]
     
     UserDefaults.standard.set(updateDict["brandid"], forKey: "selected")
     //cell.contentView.layer.borderColor = UIColor.black.cgColor
     cell.contentView.layer.borderWidth = 2.0
     cell.tagLabel.textColor = UIColor.black
     cell.tagLabel.backgroundColor = UIColor.gray
     guard let catId = updateDict["categoryid"] else {
     return
     }
     guard let subcatId = updateDict["subcategoryid"] else {
     return
     }
     if indexPath.row == 0 {
     fetchItemsdatafromServer()
     
     } else {
     guard let brandId = updateDict["brandid"] else {
     return
     }
     let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId, "brandid" : brandId]
     fetchselectedTagData(parameter: parameter)
     }
     
     }*/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let updateDict = tagView1_data[indexPath.row]
        if ((_selectedIndexPath) != nil){
            
            if indexPath.compare(_selectedIndexPath!) == ComparisonResult.orderedSame {
                
                //if the user tap the same cell that was selected previously deselect it.
                
                _selectedIndexPath = nil;
            }
            else
            {
                // save the currently selected indexPath
                _selectedIndexPath = indexPath
                
            }
        }
        else{
            
            // else, savee the indexpath for future reference if we don't have previous selected cell
            
            _selectedIndexPath = indexPath;
        }
        
        // and now only reload only the visible cells
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        guard let catId = updateDict["categoryid"] else {
            return
        }
        guard let subcatId = updateDict["subcategoryid"] else {
            return
        }
        if indexPath.row == 0 {
            fetchItemsdatafromServer()
            
        } else {
            guard let brandId = updateDict["brandid"] else {
                return
            }
            let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId, "brandid" : brandId]
            fetchselectedTagData(parameter: parameter)
        }
    }
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//
//        guard  let cell = collectionView.cellForItem(at: indexPath) as? tagCollectionCell else {
//            return
//        }
//        cell.contentView.layer.borderWidth = 0.5
//        cell.tagLabel.textColor = UIColor.black
//        cell.tagLabel.backgroundColor = UIColor.white
//    }
    func fetchselectedTagData(parameter : [String: Any]) {
        ANLoader.showLoading("Please Wait", disableUI: true)
        print("the brand products", parameter)
        global.api.postServerDataandgetResponse(urlString: global.brandProducts, parameters: parameter) { (json) in
            if (json.count < 1) {
                self.perform(#selector(self.sideMenuAction), with: nil, afterDelay: 4.0)
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
            self.itemArray = json["products"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                self.itemTable.reloadData()
            }
        }
    }
    func fetchItemsdatafromServer() {
        guard let catId = itemDict["categoryid"] else {
            return
        }
        guard let subcatId = itemDict["subcategoryid"] else {
            return
        }
        let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId]
        ANLoader.showLoading("Please Wait", disableUI: true)
        print("the brand products", parameter)
        global.api.postServerDataandgetResponse(urlString: global.getProducts, parameters: parameter) { (json) in
            if (json.count < 1) {
                self.perform(#selector(self.sideMenuAction), with: nil, afterDelay: 4.0)
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
            self.itemArray = json["products"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                self.itemTable.reloadData()
            }
        }
    }
}
/*extension ItemsViewController : HTagViewDelegate, HTagViewDataSource {
 
 // MARK: - HTagViewDataSource
 func numberOfTags(_ tagView: HTagView) -> Int {
 
 return tagView1_data.count
 }
 
 func tagView(_ tagView: HTagView, titleOfTagAtIndex index: Int) -> String {
 let dict = tagView1_data[index]
 return dict["brandname"] as! String
 }
 
 func tagView(_ tagView: HTagView, tagTypeAtIndex index: Int) -> HTagType {
 //   return index > 0 ? .select : .cancel
 return .select
 }
 
 func tagView(_ tagView: HTagView, tagWidthAtIndex index: Int) -> CGFloat {
 return .HTagAutoWidth
 //        return 150
 }
 
 // MARK: - HTagViewDelegate
 func tagView(_ tagView: HTagView, tagSelectionDidChange selectedIndices: [Int]) {
 print("tag with indices \(selectedIndices) are selected")
 print("the selected tag data is",tagView1_data[selectedIndices[0]])
 let dict = tagView1_data[selectedIndices[0]]
 guard let catId = dict["categoryid"] else {
 return
 }
 guard let subcatId = dict["subcategoryid"] else {
 return
 }
 if selectedIndices[0] == 0 {
 fetchItemsdatafromServer()
 
 } else {
 guard let brandId = dict["brandid"] else {
 return
 }
 let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId, "brandid" : brandId]
 fetchselectedTagData(parameter: parameter)
 }
 }
 func tagView(_ tagView: HTagView, didCancelTagAtIndex index: Int) {
 print("tag with index: '\(index)' has to be removed from tagView")
 // tagView.reloadData()
 }
 func fetchselectedTagData(parameter : [String: Any]) {
 ANLoader.showLoading("Please Wait", disableUI: true)
 global.api.postServerDataandgetResponse(urlString: global.brandProducts, parameters: parameter) { (json) in
 if (json.count < 1) {
 self.perform(#selector(self.sideMenuAction), with: nil, afterDelay: 4.0)
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
 self.itemArray = json["products"] as! NSArray
 DispatchQueue.main.async { [unowned self] in
 ANLoader.hide()
 self.itemTable.reloadData()
 }
 }
 }
 func fetchItemsdatafromServer() {
 guard let catId = itemDict["categoryid"] else {
 return
 }
 guard let subcatId = itemDict["subcategoryid"] else {
 return
 }
 let parameter : [String: Any] = ["categoryid" : catId, "subcategoryid" : subcatId]
 ANLoader.showLoading("Please Wait", disableUI: true)
 global.api.postServerDataandgetResponse(urlString: global.getProducts, parameters: parameter) { (json) in
 if (json.count < 1) {
 self.perform(#selector(self.sideMenuAction), with: nil, afterDelay: 4.0)
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
 self.itemArray = json["products"] as! NSArray
 DispatchQueue.main.async { [unowned self] in
 ANLoader.hide()
 // self.tagView.reloadData()
 self.itemTable.reloadData()
 }
 }
 }
 
 }*/
/*[
 ["productQuantity": 1, "productId": CAID902257928, "productDPrice": 30, "priceId": CAPD549969376, "productWeight": 1 KG, "productPrice": 35],
 ["productQuantity": 1, "productPrice": 25, "productId": CAID902257928, "productDPrice": 20, "priceId": CAPD784673092, "productWeight": 500 GMS]]*/
/*{
 products =     (
 {
 id = 25;
 productcatid = 301;
 productdesc = "Cauliflower is one of several vegetables in the species Brassica oleracea in the genus Brassica, which is in the Brassicaceae family. It is an annual plant that reproduces by seed. Typically, only the head is eaten";
 productid = CAID1811189986;
 productimage = "011970000000cauliflower.jpg";
 productinstock = 1;
 productname = Cauliflower;
 productprice = "[{\"productId\":\"CAID1811189986\",\"priceId\":\"CAPD1932427453\",\"productPrice\":16,\"productDPrice\":16,\"productWeight\":\"500 GMS\",\"productQuantity\":1},{\"productId\":\"CAID1811189986\",\"priceId\":\"CAPD2138100602\",\"productPrice\":25,\"productDPrice\":25,\"productWeight\":\"1 KG\",\"productQuantity\":1}]";
 productsubcatid = 5;
 },
 {
 id = 26;
 productcatid = 301;
 productdesc = Apples;
 productid = CAID381820736;
 productimage = "011970000000coconut-medium.jpg";
 productinstock = 250;
 productname = Apples;
 productprice = "[{\"productId\":\"CAID381820736\",\"priceId\":\"CAPD165856726\",\"productPrice\":35,\"productDPrice\":30,\"productWeight\":\"5 PCS\",\"productQuantity\":1}]";
 productsubcatid = 5;
 },
 {
 id = 16;
 productcatid = 301;
 productdesc = Hello;
 productid = CAID580296537;
 productimage = "011970000000tomato-hybrid.jpg";
 productinstock = 1;
 productname = Tomatoes;
 productprice = "[{\"productId\":\"CAID580296537\",\"priceId\":\"CAPD1410172270\",\"productPrice\":35,\"productDPrice\":30,\"productWeight\":\"1 KG\",\"productQuantity\":1},{\"productId\":\"CAID580296537\",\"priceId\":\"CAPD1618380557\",\"productPrice\":22,\"productDPrice\":20,\"productWeight\":\"500 GMS\",\"productQuantity\":1}]";
 productsubcatid = 5;
 },
 {
 id = 15;
 productcatid = 301;
 productdesc = Help;
 productid = CAID902257928;
 productimage = "011970000000beetroot.jpg";
 productinstock = 250;
 productname = Beetroot;
 productprice = "[{\"productId\":\"CAID902257928\",\"priceId\":\"CAPD549969376\",\"productPrice\":35,\"productDPrice\":30,\"productWeight\":\"1 KG\",\"productQuantity\":1},{\"productId\":\"CAID902257928\",\"priceId\":\"CAPD784673092\",\"productPrice\":25,\"productDPrice\":20,\"productWeight\":\"500 GMS\",\"productQuantity\":1}]";
 productsubcatid = 5;
 }
 );
 }*/

