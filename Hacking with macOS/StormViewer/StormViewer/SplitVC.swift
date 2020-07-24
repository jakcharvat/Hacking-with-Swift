//
//  SplitVC.swift
//  StormViewer
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class SplitVC: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func shareTapped(_ sender: NSView) {
        guard let detail = children[1] as? DetailVC else { return }
        guard let image = detail.imageView.image else { return }
        
        let picker = NSSharingServicePicker(items: [ image ])
        picker.show(relativeTo: .zero, of: sender, preferredEdge: .minY)
    }
    
    @IBAction func alertTapped(_ sender: NSView) {
        let alert = NSAlert()
        alert.messageText = "This is my alert"
        alert.informativeText = "This is my alert's info text"
        alert.beginSheetModal(for: view.window!)
    }
}

