//
//  AppDelegate.swift
//  TextTransformer
//
//  Created by Jakub Charvat on 29/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.button?.title = "𝒂"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showSettings)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc private func showSettings() {
        let storyboard = NSStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("Unable to find ViewController in Storyboard")
        }
        
        let popover = NSPopover()
        popover.contentViewController = vc
        popover.behavior = .transient
        
        guard let statusButton = statusItem.button else { fatalError("Couldn't find statusItem button") }
        popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .maxY)
    }
}

