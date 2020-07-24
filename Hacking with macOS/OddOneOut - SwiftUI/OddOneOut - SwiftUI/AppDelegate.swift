//
//  AppDelegate.swift
//  OddOneOut - SwiftUI
//
//  Created by Jakub Charvat on 03/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        let blurView = NSVisualEffectView()
        blurView.material = .underWindowBackground
        blurView.blendingMode = .behindWindow
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        blurView.addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: hostingView.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor),
        ])
        
        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = blurView
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

