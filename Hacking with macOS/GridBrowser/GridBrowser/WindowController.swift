//
//  WindowController.swift
//  GridBrowser
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet var addressEntry: NSTextField!
    @IBOutlet var refreshButton: NSButton!
    @IBOutlet var navigationButtons: NSSegmentedControl!
    @IBOutlet var loadingIndicator: NSView!
    
    private var widthConstraint: NSLayoutConstraint!

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.titleVisibility = .hidden
        
        loadingIndicator.wantsLayer = true
        loadingIndicator.layer?.backgroundColor = NSColor.systemBlue.cgColor
    }
    
    
    func setLoadingPercentage(_ percentage: Double) {
        if let existing = widthConstraint {
            existing.isActive = false
        }
        
        widthConstraint = loadingIndicator.widthAnchor.constraint(equalTo: addressEntry.widthAnchor, multiplier: CGFloat(percentage))
        widthConstraint.isActive = true
        
        if percentage == 1 {
            #warning("Add Animation")
            loadingIndicator.alphaValue = 0
        } else {
            loadingIndicator.alphaValue = 1
        }
    }
    
    
    override func cancelOperation(_ sender: Any?) {
        window?.makeFirstResponder(contentViewController)
    }
}
