//
//  ViewController.swift
//  GridBrowser
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    lazy private var touchbarManager: ViewControllerTouchbarManager = {
        let manager = ViewControllerTouchbarManager()
        manager.viewController = self
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        NSLayoutConstraint.activate([
            rows.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rows.topAnchor.constraint(equalTo: view.topAnchor),
            rows.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let row = NSStackView(views: [ makeWebView() ])
        row.distribution = .fillEqually
        
        rows.addArrangedSubview(row)
    }

    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "http://apple.com")!))
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked(recognizer:)))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webView)
        }
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        return webView
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.systemBlue.cgColor
        
        if let wc = view.window?.windowController as? WindowController {
            wc.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    @objc func webViewClicked(recognizer: NSClickGestureRecognizer) {
        guard let newSelectedWebView = recognizer.view as? WKWebView else { return }
        
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        
        select(webView: newSelectedWebView)
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return touchbarManager.makeTouchBar()
    }
}


//MARK: - Responder Chain
extension ViewController {
    @IBAction func urlEntered(_ sender: NSTextField) {
        view.window?.makeFirstResponder(self)
        guard let selected = selectedWebView else { return }
        
        if let url = URL(string: sender.stringValue) {
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        guard let selected = selectedWebView else { return }
        
        if sender.selectedSegment == 0 {
            selected.goBack()
        } else {
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add a row
            guard let colCount = (rows.arrangedSubviews.first as? NSStackView)?.arrangedSubviews.count else { return }
            let webViews = (1...colCount).map { _ in makeWebView() }
            
            let row = NSStackView(views: webViews)
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            // Delete a row
            guard rows.arrangedSubviews.count > 1 else { return }
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            
            for cell in rowToRemove.arrangedSubviews {
                cell.removeFromSuperview()
            }
            
            rows.removeArrangedSubview(rowToRemove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // Add a column
            for case let row as NSStackView in rows.arrangedSubviews {
                row.addArrangedSubview(makeWebView())
            }
        } else {
            // Remove a column
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            guard firstRow.arrangedSubviews.count > 1 else { return }
            
            for case let row as NSStackView in rows.arrangedSubviews {
                if let last = row.arrangedSubviews.last {
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
    
    @IBAction func refreshClicked(_ sender: NSButton) {
        guard let selected = selectedWebView else { return }
        
        if selected.isLoading {
            selected.stopLoading()
            sender.image = NSImage(named: NSImage.refreshTemplateName)
        } else {
            selected.reload()
        }
    }
}


//MARK: - WK Nav Delegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        
        if let wc = view.window?.windowController as? WindowController {
            wc.addressEntry.stringValue = webView.url?.absoluteString ?? ""
            wc.refreshButton.image = NSImage(named: NSImage.stopProgressTemplateName)
            
            wc.navigationButtons.setEnabled(webView.canGoBack, forSegment: 0)
            wc.navigationButtons.setEnabled(webView.canGoForward, forSegment: 1)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let wc = view.window?.windowController as? WindowController else { return }
        wc.refreshButton.image = NSImage(named: NSImage.refreshTemplateName)
    }
}


//MARK: - Loading Progress KVO
extension ViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if let webView = object as? WKWebView, webView == selectedWebView {
                if let wc = view.window?.windowController as? WindowController {
                    wc.setLoadingPercentage(webView.estimatedProgress)
                }
            }
        }
    }
}



//MARK: - Gesture Rec Delegate
extension ViewController: NSGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        return selectedWebView != gestureRecognizer.view
    }
}
