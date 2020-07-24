//
//  DetailVC.swift
//  StormViewer
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class DetailVC: NSViewController {

    @IBOutlet var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    func imageSelected(name: String) {
        imageView.image = NSImage(named: name)
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.nameTextField.stringValue = "\(name) - Storm Viewer"
        }
    }
    
}
