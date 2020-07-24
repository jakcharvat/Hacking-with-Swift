//
//  WebViewController.swift
//  Project16
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private var webView: WKWebView!
    
    var cityName: String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        openCityWiki()
    }
    
    private func openCityWiki() {
        guard let cityName = cityName,
            let encoded = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://en.wikipedia.org/wiki/\(encoded)") else { dismiss(animated: true); return }
        
        title = cityName
        
        webView.load(URLRequest(url: url))
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url,
            let host = url.host,
            host.contains("wikipedia") else { decisionHandler(.cancel); return }
        
        decisionHandler(.allow)
        
    }
}
