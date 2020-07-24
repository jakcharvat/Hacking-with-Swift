//
//  ViewController.swift
//  Project4
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    
    var website: String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButtonItem = UIBarButtonItem(customView: progressView)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 20
        let flexSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: webView, action: #selector(webView.goBack))
        let forwardItem = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: webView, action: #selector(webView.goForward))
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        
        toolbarItems = [backItem, spacer, forwardItem, flexSpacer, progressButtonItem, flexSpacer, refresh]
        navigationController?.isToolbarHidden = false
        navigationItem.largeTitleDisplayMode = .never
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://\(website!)")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}


//MARK: - WebView Navigation
extension WebViewController {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        title = "Loading..."
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            if host.contains(website!) {
                decisionHandler(.allow)
                return
            }
        }
        
        let ac = UIAlertController(title: "Disallowed Domain", message: "The page you tried to access is not allowed.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "I Understand", style: .cancel, handler: nil))
        present(ac, animated: true)
        
        decisionHandler(.cancel)
        
    }
}


// KVO - "Key-value observing" - "Key-value observing is a Cocoa programming pattern you use to notify objects about changes to properties of other objects." https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift
//MARK: - KVO
extension WebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}
