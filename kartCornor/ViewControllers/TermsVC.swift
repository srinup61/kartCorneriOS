//
//  TermsVC.swift
//  kartCornor
//
//  Created by Srinivas on 09/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import PDFKit

class TermsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.addcolorToBar()
        let btnleft : UIButton = UIButton(frame: CGRect(x:0, y:0, width:35, height:35))
        btnleft.setTitleColor(UIColor.white, for: .normal)
        btnleft.contentMode = .left
        
        btnleft.setImage(UIImage(named :"burger"), for: .normal)
        btnleft.addTarget(self, action: #selector(sideMenuAction), for: .touchDown)
        let backBarButon: UIBarButtonItem = UIBarButtonItem(customView: btnleft)
        
        // self.navigationItem.setLeftBarButtonItems([backBarButon], animated: false)
        self.navigationItem.leftBarButtonItem = backBarButon
        // Add PDFView to view controller.
        let pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(pdfView)
        
        // Fit content in PDFView.
        // pdfView.autoScales = true
        pdfView.autoScales = true
        guard let path = Bundle.main.url(forResource: "Terms&Conditions", withExtension: "pdf") else { return }
        
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
