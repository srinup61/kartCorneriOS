//
//  SubCategoryController.swift
//  kartCornor
//
//  Created by Srinivas on 07/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke
import Alamofire

class SubCategoryController: UIViewController, ModernSearchBarDelegate {
    var categoryDict : NSDictionary = NSDictionary()
    var jsonArr : NSArray = NSArray()
    @IBOutlet weak var collectionView: UICollectionView!
    var suggestionArray = Array<String>()
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    
    var categoryArray = NSArray()
    var allProducts = [[String : Any]]()
    var itemDesc = NSDictionary()
    var categoryName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.addcolorToBar()
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16)!]
        self.modernSearchBar.delegateModernSearchBar = self
        if UserDefaults.standard.bool(forKey: global.KUserLogged) {
        let cartBtn = UIBarButtonItem.menuButton(self, action: #selector(cartView), imageName: "shop")
        self.navigationItem.rightBarButtonItem = cartBtn
        let badgeCount = UserDefaults.standard.string(forKey: "badgeData")
        if badgeCount == "0" || badgeCount?.isEmpty ?? true {
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
        self.title = categoryName
        guard let id = categoryDict["categoryid"] else {return}
        
        gettingSubCategories(id: id)
        //categoryData
        self.suggestionArray = UserDefaults.standard.object(forKey: "searchArray") as! Array<String>
        self.allProducts = UserDefaults.standard.object(forKey: "allProducts") as! [[String : Any]]
        categoryArray = UserDefaults.standard.object(forKey: "categoryData") as! NSArray
        self.modernSearchBar.setDatas(datas: self.suggestionArray)
        print(suggestionArray)
    }
    @objc func loginView() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
         loginVC.modalPresentationStyle = .overCurrentContext
         loginVC.providesPresentationContextTransitionStyle = true
         loginVC.definesPresentationContext =  true
         self.present(loginVC, animated: true, completion: nil)
     }
    @objc func cartView() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : ShoppingCartVC = storyboard.instantiateViewController(withIdentifier: "cartVC") as! ShoppingCartVC
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        collectionView.dataSource = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.dataSource = self
    }
    func gettingSubCategories(id:Any) {
        print(type(of: id))
        
        let parameter : [String: Any] = ["categoryid" : id]
        ANLoader.showLoading("Please Wait", disableUI: true)
        global.api.postServerDataandgetResponse(urlString: global.subcategories, parameters: parameter) { (json) in
            // print(json);
            if (json.count == 0) {
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
            self.jsonArr = json["subcategories"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                ANLoader.hide()
                print("sub category data",json)
                self.collectionView.reloadData()
            }
        }
    }
    @objc func sideMenuAction() {
        self.navigationController?.popViewController(animated: true)
        // self.navigationController?.dismiss(animated: false, completion:nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemsVC" {
            let cell = sender as! UICollectionViewCell
            if let indexPath = self.collectionView.indexPath(for: cell) {
                let controller = segue.destination as! ItemsViewController
                //subcategoryname
                let dict = jsonArr[indexPath.row] as! NSDictionary
                controller.itemName = dict["subcategoryname"] as! String
                controller.itemDict = dict
            }
        }
    }
    ///Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: "+item)
        
        for i in 0...allProducts.count - 1 {
            let dict : [String : Any] = allProducts[i]
            print("matching are", dict["productname"]!)
            let prodStr = dict["productname"] as! String
//            guard let prodId = dict["productname"] else {
//                return
//            }
           // print("product details are", prodId,item)
           // if prodId as AnyObject === item as AnyObject  {
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
}
extension SubCategoryController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource , UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categoryArray.count
        } else {
            return jsonArr.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionCell
        cell.contentView.addBorderToview()
        if collectionView == categoryCollectionView {
            let dict = categoryArray[indexPath.row] as! [String:Any]
            cell.detailLabel.text = (dict["categoryname"] as! String)
                if categoryDict["categoryid"] as! Int == dict["categoryid"] as! Int {
                    cell.contentView.layer.borderColor = UIColor.red.cgColor
                    cell.contentView.layer.borderWidth = 1.0
                    cell.detailLabel.textColor = UIColor.red
                } else {
                    cell.contentView.layer.borderColor = UIColor.black.cgColor
                    cell.contentView.layer.borderWidth = 0.6
                    cell.detailLabel.textColor = UIColor.black
                }
            if URL(string: dict["categoryimage"]! as! String) == nil {
                
            } else {
              //  let url = URL(string: dict["categoryimage"]! as! String)
                let url_str = global.imagePath + (dict["categoryimage"]! as! String)
                let url = URL(string: url_str)
                Nuke.loadImage(with: url!, into: cell.imageView)
            }
        } else {
            let dict = jsonArr[indexPath.row] as! NSDictionary
            cell.detailLabel.text = (dict["subcategoryname"] as! String)
           // let url = URL(string: dict["subcategoryimage"]! as! String)
            let url_str = global.imagePath + (dict["subcategoryimage"]! as! String)
            let url = URL(string: url_str)
            if url == nil {
                cell.imageView.image = UIImage(named: "noimage.jpg")
            } else {
                Nuke.loadImage(with: url!, into: cell.imageView)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 1
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionCell else {
                return
            }
            cell.contentView.layer.borderColor = UIColor.red.cgColor
            cell.contentView.layer.borderWidth = 2.0
            cell.detailLabel.textColor = UIColor.red
            let dict = self.categoryArray[indexPath.row] as! NSDictionary
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16)!]
            self.title = (dict["categoryname"] as! String)
            categoryDict = dict
            categoryCollectionView.reloadData()
            gettingSubCategories(id: dict["categoryid"]! as Any)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionCell else {
            return
        }
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        // cell.contentView.backgroundColor = .white
        cell.contentView.layer.borderWidth = 0.5
        cell.detailLabel.textColor = UIColor.black
    }
}

extension ModernSearchBar {
    func makingSearchBarAwesome() {
        layer.borderWidth = 0
        layer.borderColor = UIColor(red: 181, green: 240, blue: 210, alpha: 1).cgColor
    }
}
