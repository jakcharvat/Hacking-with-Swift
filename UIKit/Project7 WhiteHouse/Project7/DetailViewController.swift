//
//  DetailViewController.swift
//  Project7
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        initPetitionPage()
    }
    
    
    private func initPetitionPage() {
        guard let detailItem = detailItem else { return }
        
        guard let htmlUrl = Bundle.main.url(forResource: "PetitionPage", withExtension: "html") else { return }
        guard let htmlTemplate = try? String(contentsOf: htmlUrl) else { return }
        
        let parameters = [detailItem.title,
                          detailItem.body,
                          UIColor.label.hexString,
                          UIColor.secondaryLabel.hexString,
                          UIColor.systemBackground.hexString]
        
        let html = populateTemplate(htmlTemplate, with: parameters)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func populateTemplate(_ template: String, with parameters: [String]) -> String {
        var temp = template
        
        for (index, param) in parameters.enumerated() {
            temp = temp.replacingOccurrences(of: "#\(index)", with: param)
        }
        
        return temp
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        initPetitionPage()
    }
    
    
}


extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format:"#%06x", rgb)
    }
}
