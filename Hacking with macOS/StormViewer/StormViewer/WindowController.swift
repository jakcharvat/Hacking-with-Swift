//
//  WindowController.swift
//  StormViewer
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    @IBOutlet private var shareButton: NSButton!
    @IBOutlet var nameTextField: NSTextField!

    override func windowDidLoad() {
        super.windowDidLoad()
    
        shareButton.sendAction(on: .leftMouseDown)
    }

}
