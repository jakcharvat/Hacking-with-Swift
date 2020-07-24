//
//  ViewController.swift
//  Bookworm
//
//  Created by Jakub Charvat on 17/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @objc dynamic var reviews = [Review]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.isMovableByWindowBackground = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

