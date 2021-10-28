//
//  HomeViewController.swift
//  kartCornor
//
//  Created by Srinivas on 20/07/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Nuke

class HomeViewController: UIViewController, ModernSearchBarDelegate {
    
    
    @IBOutlet weak var modernSearchBar: ModernSearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var bannerArray = NSArray()
    var lowerbannerArray = NSArray()
    var categoryArray = NSArray()
    var suggestionArray = Array<String>()
    var allProducts = [[String : Any]]()
    
    var itemDesc = NSDictionary()
   // var isReachable = Bool()
    
     var imagesArray = [UIImage]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    @IBAction func sideMenuAction(_ sender: Any) {
        sideMenuManager?.toggleSideMenuView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //UICollectionElementKindSectionHeader
       // checkingNetworkAvailability()
        
        self.navigationController?.addcolorToBar()
        if collectionView == nil {
            return
        }
        collectionView.register(footerCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerCell")  // UICollectionReusableView//UICollectionElementKindSectionHeader
        UserDefaults.standard.set(false, forKey: "sidemenu")
        UserDefaults.standard.synchronize()
        
        if  UserDefaults.standard.bool(forKey: global.KUserLogged) {
            let cartBtn = UIBarButtonItem.menuButton(self, action: #selector(cartView), imageName: "shop")
            let badgeCount = UserDefaults.standard.string(forKey: "badgeData")
            if badgeCount == "0" || badgeCount?.isEmpty ?? true {
                cartBtn.removeBadge()
            } else {
                  cartBtn.addBadge(text: badgeCount!)
            }
            let monthbadgeCount = UserDefaults.standard.string(forKey: "monthbadgeData")
            let monthCart = UIBarButtonItem.menuButton(self, action: #selector(monthView), imageName: "month")
            if monthbadgeCount == "0" || monthbadgeCount?.isEmpty ?? true {
                monthCart.removeBadge()
            } else {
                monthCart.addBadge(text: monthbadgeCount!)
            }
            let weekbadgeCount = UserDefaults.standard.string(forKey: "weekbadgeData")
            let weekCart = UIBarButtonItem.menuButton(self, action: #selector(weekView), imageName: "week")
            if weekbadgeCount == "0" || weekbadgeCount?.isEmpty ?? true {
                weekCart.removeBadge()
            } else {
                weekCart.addBadge(text: weekbadgeCount!)
            }
            let offerCart = UIBarButtonItem.menuButton(self, action: #selector(offerView), imageName: "offer")
            self.navigationItem.rightBarButtonItems = [offerCart,weekCart,monthCart,cartBtn]
        } else {
            let monthCart = UIBarButtonItem.menuButton(self, action: #selector(loginView), imageName: "login")
            self.navigationItem.rightBarButtonItems = [monthCart]
        }
        barButton.image = UIImage(named: "burger")?.withRenderingMode(.alwaysOriginal)
        // Update side menu
        sideMenuManager?.instance()?.menu?.isNavbarHiddenOrTransparent = true
        // Re-enable sidemenu
        sideMenuManager?.instance()?.menu?.disabled = false
        self.modernSearchBar.delegateModernSearchBar = self
        self.addTitle()
        pagerView.addBorder()
        // Categories
        self.getlowerslides()
        self.modernSearchBar.makingSearchBarAwesome()
        // startHost(at: 0)
    }
    
    func getlowerslides() {
        global.api.gettingServerResponse(urlString: global.lowerSlides) { (json) in
            //  print("slide data is ",json)
            if json.count == 0 {
                self.callingToast()
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.lowerbannerArray = json["banners"] as! NSArray
                //self.collectionView.reloadData()
                for i in 0...self.lowerbannerArray.count - 1 {
                    let dict = self.lowerbannerArray[i] as! [String:Any]
                    if let url = URL(string: dict["bannerurl"] as! String) {
                        print("first one image url",url)
                       // dispatchGroup.enter()
                        URLSession.shared.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
                            if let data = data, let image = UIImage(data: data) {
                                self.imagesArray.append(image)
                                self.getupperslides()
                               // dispatchGroup.leave()
                               // print("images data is ",self.imagesArray)
                            }
                        }).resume()
                    }
                }
            }
        }
    }
    func getupperslides() {
        global.api.gettingServerResponse(urlString: global.slideUrl) { (json) in
            //  print("slide data is ",json)
            if json.count == 0 {
                self.callingToast()
                return
            }
            self.bannerArray = json["banners"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                self.getallcategories()
                self.pagerView.reloadData()
            }
        }
    }
    func getallcategories() {
        global.api.gettingServerResponse(urlString: global.allCategories) { (json) in
            
            if json.count == 0 {
                self.callingToast()
                return
            }
            self.categoryArray = json["categories"] as! NSArray
            DispatchQueue.main.async { [unowned self] in
                UserDefaults.standard.set(self.categoryArray, forKey: "categoryData")
                self.collectionView.reloadData()
                self.getallProducts()
            }
        }
    }
    func displayInternetAlert() {
        SCLAlertView().showInfo("Important info", subTitle: "Please check your internet connection and try again")
    }
   @objc func loginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.providesPresentationContextTransitionStyle = true
        loginVC.definesPresentationContext =  true
        self.present(loginVC, animated: true, completion: nil)
    }
    func addTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.width - 32, height: view.frame.height))
            titleLabel.text = "Cart Corner"
            titleLabel.textColor = UIColor.white
          //  titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
            navigationItem.titleView = titleLabel
    }
    func callingToast() {
        DispatchQueue.main.async {
            var style = ToastStyle()
            // this is just one of many style options
            style.messageColor = .red
            style.backgroundColor = .lightGray
            self.view.makeToast("data not found.Please Try Again", duration: 3.0, position: .bottom, style: style)
            // toggle "tap to dismiss" functionality
            ToastManager.shared.isTapToDismissEnabled = true
        }
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
  /*  func checkingNetworkAvailability() {
        //        //declare this property where it won't go out of scope relative to your listene
        //  let status = Reach().connectionStatus()//declare this property where it won't go out of scope relative to your listener
        let reachability = try! Reachability()
        
        reachability.whenReachable = { reachability in
            self.isReachable = true
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.isReachable = false
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        //declare this inside of viewWillAppear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            self.isReachable = true
            print("Reachable via WiFi")
        case .cellular:
            self.isReachable = true
            print("Reachable via Cellular")
        case .unavailable:
            self.isReachable = false
            print("Network not reachable")
        case .none:
            self.isReachable = false
            print("Network none")
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryVC" {
            let cell = sender as! UICollectionViewCell
          //  cell.contentView.backgroundColor = UIColor.gray
            if let indexPath = self.collectionView.indexPath(for: cell) {
                let controller = segue.destination as! SubCategoryController
                //categoryname
                let dict = categoryArray[indexPath.row] as! NSDictionary
                controller.categoryName = dict["categoryname"] as! String
                controller.categoryDict = dict
            }
        } else if segue.identifier == "homeSearch" {
            let controller = segue.destination as! itemDescriptionVC
            controller.itemDict = itemDesc
        }
    }
    
    func getallProducts() {
        global.api.gettingServerResponse(urlString: global.allProducts) { (json) in
            
            self.allProducts = json["products"] as! [[String : Any]]
            let  prods = json["products"]
            ANLoader.hide()
            // print(prods)
            // DispatchQueue.main.async {
           // print("test")
            if let items = prods  {
                for item in items as! [[String:Any]] {
                  //  print(item["productname"]!)
                    self.suggestionArray.append(item["productname"]! as! String)
                }
            }
            UserDefaults.standard.set(self.suggestionArray, forKey: "searchArray")
            UserDefaults.standard.set(self.allProducts, forKey: "allProducts")
            UserDefaults.standard.synchronize()
            ///Set datas to search bar
            self.modernSearchBar.setDatas(datas: self.suggestionArray)
            //   }
        }
    }
    
    ///Called if you use String suggestion list
    func onClickItemSuggestionsView(item: String) {
        print("User touched this item: "+item)
        self.view.endEditing(true)
        for i in 0...allProducts.count - 1 {
            let dict : [String : Any] = allProducts[i]
            print("the item is",dict["productname"] as AnyObject)
            let prodName = dict["productname"] as! String
            if prodName.lowercased() == item.lowercased()   {
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
        // print(op)
    }
    
    ///Called when user touched shadowView
    func onClickShadowView(shadowView: UIView) {
        print("User touched shadowView")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text did change, what i'm suppose to do ?")
        print("User touched this item: "+searchText)
        //self.view.endEditing(true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if (allProducts.count < 0){
            self.view.endEditing(true)
            return
        }
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
    @objc func cartView() {
        print("Cartiew")
       
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : ShoppingCartVC = storyboard.instantiateViewController(withIdentifier: "cartVC") as! ShoppingCartVC
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func monthView() {
        print("month view")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : MonthlyCartVC = storyboard.instantiateViewController(withIdentifier: "monthlyVC") as! MonthlyCartVC
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func weekView() {
        print("week view")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : WeeklyCartVC = storyboard.instantiateViewController(withIdentifier: "weeklyVC") as! WeeklyCartVC
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func offerView() {
        print("offer view")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let itemView : OfferViewController = storyboard.instantiateViewController(withIdentifier: "offerVC") as! OfferViewController
        let nav = UINavigationController(rootViewController: itemView)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension HomeViewController : FSPagerViewDataSource {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return bannerArray.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let imageUrl = bannerArray[index] as! NSDictionary
      //  let url = URL(string: imageUrl["bannerurl"] as! String)
        let url_str = global.imgUrl + (imageUrl["bannerurl"]! as! String)
        let url = URL(string: url_str)
       // print("Banner image is",url)
        if url == nil {
            
        } else {
            Nuke.loadImage(with: url!, into: cell.imageView!)
        }
        return cell
    }
}

extension HomeViewController : UICollectionViewDataSource,  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCell", for: indexPath) as! HomeCollectionCell
        
        cell.contentView.addBorderToview()
        let dict = categoryArray[indexPath.row] as! [String:Any]
        print("The collection dict is", dict)
        cell.detailLabel.text = (dict["categoryname"] as! String)
        
        if URL(string: dict["categoryimage"]! as! String) == nil {
            
        } else {
            let url_str = global.imagePath + (dict["categoryimage"]! as! String)
            let url = URL(string: url_str)
        print("The url is",url!)
        Nuke.loadImage(with: url!, into: cell.imageView)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 2
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionView.elementKindSectionFooter) {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath) as! footerCell
           // print(type(of: imagesArray))
           //  let dispatchGroup = DispatchGroup()
            let imgView = UIImageView()
            imgView.frame = CGRect(x: 0, y: 0, width: footerView.frame.size.width, height: footerView.frame.size.height)
            footerView.addSubview(imgView)
            imgView.addBorderToview()
            if imagesArray.count > 0 {
              //  dispatchGroup.notify(queue: DispatchQueue.main) {
                    print("calling")
                   imgView.animationImages = self.imagesArray.compactMap({$0})
                    imgView.animationDuration = 10.0
                    imgView.startAnimating()
              //  }
            }
           
            return footerView
        }
        fatalError()
    }
}
/*
 
 
 
 
 func downloadImages() {
 let imageUrls = [String]()
 var imagesArray = [UIImage]()
 
 let dispatchGroup = DispatchGroup()
 dispatchGroup.notify(queue: DispatchQueue.main) {[weak self] in
 self?.imageView.animationImages = imagesArray.compactMap({$0})
 self?.imageView.animationDuration = 2.0
 self?.imageView.startAnimating()
 }
 
 imageUrls.forEach { (imageUrl) in
 if let url = URL(string: imageUrl) {
 dispatchGroup.enter()
 URLSession.shared.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
 if let data = data, let image = UIImage(data: data) {
 imagesArray.append(image)
 dispatchGroup.leave()
 }
 }).resume()
 }
 }
 }*/
extension UIBarButtonItem {
    
    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
     //   button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setImage(UIImage(named: imageName)!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.black
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        return menuBarItem
    }
}
extension FSPagerView {
    func addBorder() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        automaticSlidingInterval = 5.0
    }
}
extension UINavigationController {
    func addcolorToBar() {
        let gradientLayer = CAGradientLayer()
            var updatedFrame = self.navigationBar.bounds
            updatedFrame.size.height += UIApplication.shared.statusBarFrame.size.height
            gradientLayer.frame = updatedFrame
            gradientLayer.colors = [UIColor.red.cgColor, UIColor.white.cgColor] // start color and end color
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // Horizontal gradient start
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0) // Horizontal gradient end
            UIGraphicsBeginImageContext(gradientLayer.bounds.size)
            gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
    }
}
/*extension HomeViewController {
 func startHost(at index: Int) {
 stopNotifier()
 setupReachability(hostNames[index], useClosures: true)
 startNotifier()
 DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
 self.startHost(at: (index + 1) % 3)
 }
 }
 
 func setupReachability(_ hostName: String?, useClosures: Bool) {
 let reachability: Reachability?
 if let hostName = hostName {
 reachability = try? Reachability(hostname: hostName)
 //  hostNameLabel.text = hostName
 print(hostName)
 } else {
 reachability = try? Reachability()
 // hostNameLabel.text = "No host name"
 print("no hostName")
 }
 self.reachability = reachability
 // print("--- set up with host name: \(hostNameLabel.text!)")
 
 if useClosures {
 reachability?.whenReachable = { reachability in
 self.updateLabelColourWhenReachable(reachability)
 }
 reachability?.whenUnreachable = { reachability in
 self.updateLabelColourWhenNotReachable(reachability)
 }
 } else {
 NotificationCenter.default.addObserver(
 self,
 selector: #selector(reachabilityChanged(_:)),
 name: .reachabilityChanged,
 object: reachability
 )
 }
 }
 
 func startNotifier() {
 print("--- start notifier")
 do {
 try reachability?.startNotifier()
 } catch {
 self.view.backgroundColor = .red
 // networkStatus.text = "Unable to start\nnotifier"
 print("Unable to start\nnotifier")
 return
 }
 }
 
 func stopNotifier() {
 print("--- stop notifier")
 reachability?.stopNotifier()
 NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
 reachability = nil
 }
 
 func updateLabelColourWhenReachable(_ reachability: Reachability) {
 print("\(reachability.description) - \(reachability.connection)")
 if reachability.connection == .wifi {
 self.view.backgroundColor = .green
 } else {
 self.view.backgroundColor = .blue
 }
 
 print("\(reachability.connection)")
 }
 
 func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
 print("\(reachability.description) - \(reachability.connection)")
 
 self.view.backgroundColor = .red
 
 // self.networkStatus.text = "\(reachability.connection)"
 print("\(reachability.connection)")
 }
 
 @objc func reachabilityChanged(_ note: Notification) {
 let reachability = note.object as! Reachability
 
 if reachability.connection != .unavailable {
 updateLabelColourWhenReachable(reachability)
 } else {
 updateLabelColourWhenNotReachable(reachability)
 }
 }
 }*/
