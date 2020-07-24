//
//  ViewController.swift
//  Project31
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController {
    
    @IBOutlet var addressBar: UITextField!
    @IBOutlet var stackView: UIStackView!
    
    weak var activeWebView: WKWebView?
    
    var hintLabel: UILabel!
    
}


//MARK: - Setup
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createHintLabel()
        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [ delete, add ]
        
        addressBar.delegate = self
    }

    func setDefaultTitle() {
        title = "Multibrowser"
    }
}


//MARK: - Hint Label
extension ViewController {
    func createHintLabel() {
        let attributedString = NSMutableAttributedString(string: "No WebViews 😞\nTap the plus icon to get started...")
        attributedString.addAttributes([
            .font: UIFont.preferredFont(forTextStyle: .title1)
        ], range: NSRange(location: 0, length: "No WebViews".count))
        
        hintLabel = UILabel()
        hintLabel.numberOfLines = 2
        hintLabel.attributedText = attributedString
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)
        view.sendSubviewToBack(hintLabel)
        
        hintLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
    }
}


//MARK: - Adding WebViews
extension ViewController {
    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.systemBlue.cgColor
        selectWebView(webView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(webViewTapped(_:)))
        tap.delegate = self
        webView.addGestureRecognizer(tap)
        
        hintLabel.isHidden = true
    }
}


//MARK: - Deleting WebViews
extension ViewController {
    @objc func deleteWebView() {
        guard let webView = activeWebView,
            let index = stackView.arrangedSubviews.firstIndex(of: webView) else { return }
        
        webView.removeFromSuperview()
        
        if stackView.arrangedSubviews.count == 0 {
            setDefaultTitle()
            hintLabel.isHidden = false
            return
        }
        
        var currentIndex = Int(index)
        if currentIndex == stackView.arrangedSubviews.count {
            currentIndex = stackView.arrangedSubviews.count - 1
        }
        
        if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
            selectWebView(newSelectedWebView)
        }
        
    }
}


//MARK: - Selecting a WebView
extension ViewController {
    func selectWebView(_ webView: WKWebView) {
        
        for view in stackView.arrangedSubviews {
            if view == webView {
                view.layer.borderWidth = 3
            } else {
                view.layer.borderWidth = 0
            }
        }
        
        activeWebView = webView
        updateUI(for: webView)
    }
    
    func updateUI(for webView: WKWebView) {
        title = webView.title
        
        if !addressBar.isFirstResponder {
            addressBar.text = webView.url?.absoluteString ?? ""
        }
    }
}


//MARK: - WebView Tap
extension ViewController {
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
}


//MARK: - Responsive Design
extension ViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
}


//MARK: - WK Navigation Delegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
}

//MARK: - Gesture Recognizer Delegate
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}


//MARK: - Text Field Delegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, var address = addressBar.text {
            
            if !address.hasPrefix("https://") {
                if address.contains("https://") {
                    let split = address.components(separatedBy: "https://")
                    address = "https://\(split.last!)"
                } else {
                    address = "https://\(address)"
                }
            }
            
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        textField.selectAll(nil)
    }
}
