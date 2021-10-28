//
//  AboutUsVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import PDFKit

class AboutUsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        btnleft.setTitleColor(UIColor.white, for: .normal)
        btnleft.contentMode = .left
        self.navigationController?.addcolorToBar()
        btnleft.setImage(UIImage(named :"burger"), for: .normal)
        btnleft.addTarget(self, action: #selector(sideMenuAction), for: .touchDown)
        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)
        
        // self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        self.navigationItem.leftBarButtonItem = backBarButon
        
        
        // Add PDFView to view controller.
        let pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(pdfView)
        pdfView.autoScales = true
        // Fit content in PDFView.
        // pdfView.autoScales = true
        
        guard let path = Bundle.main.url(forResource: "aboutus", withExtension: "pdf") else { return }
        
        if let document = PDFDocument(url: path) {
            pdfView.document = document
            // pdfView.displayMode = .singlePage
        }
    }
    
    @objc func sideMenuAction() {
        sideMenuManager?.toggleSideMenuView()
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
/*  let order = PGOrder(params: params)

     let txnController = PGTransactionViewController(transactionFor: order)
     txnController?.serverType = eServerTypeStaging
     txnController?.merchant = PGMerchantConfiguration.default()
     txnController?.merchant.checksumGenerationURL = CheckSumGenerationURL
     txnController?.merchant.merchantID = "FlotaS90100524961231"
     txnController?.merchant.checksumValidationURL = CheckSumVerifyURL + orderID
     txnController?.loggingEnabled = true
     txnController?.merchant.website = "APPSTAGING"
     txnController?.merchant.industryID = "Retail"
     txnController?.serverType = eServerTypeStaging
     txnController?.delegate = self

     self.navigationController?.pushViewController(txnController!, animated: true)*/
/*   func didSucceedTransaction(controller: PGTransactionViewController, response: [NSObject : AnyObject]) {
       print(response)
   }

   func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
       print(responseString) // Response will be in string
        let data = responseString.data(using: .utf8)!
   let obj = JSON(data: data)
   if obj["STATUS"].stringValue != "TXN_SUCCESS" {
      //handle what you want
   }
    }
   }
   func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
       print(error)

   }

   func didCancelTrasaction(_ controller: PGTransactionViewController!) {
       print("User camcelled the trasaction")
       controller.navigationController?.popViewController(animated: true)
   }

   func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
       print(error.localizedDescription)
       controller.navigationController?.popViewController(animated: true)
   }*/
