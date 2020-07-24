//
//  ViewControllerTouchbarManager.swift
//  GridBrowser
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import AppKit

class ViewControllerTouchbarManager: NSObject, NSTouchBarDelegate {
    weak var viewController: ViewController!
    
    
    func makeTouchBar() -> NSTouchBar {
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        let touchbar = NSTouchBar()
        touchbar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("dev.jakcharvat.gridbrowser")
        touchbar.delegate = self
        
        touchbar.defaultItemIdentifiers = [ .navigation, .adjustGrid, .enterAddress, .sharingPicker ]
        touchbar.principalItemIdentifier = .enterAddress
        touchbar.customizationAllowedItemIdentifiers = [ .sharingPicker, .adjustGrid, .adjustCols, .adjustRows ]
        touchbar.customizationRequiredItemIdentifiers = [ .enterAddress ]
        
        return touchbar
    }
    
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        let tbItem = NSCustomTouchBarItem(identifier: identifier)
        
        switch identifier {
        case .enterAddress:
            let button = NSButton(title: "Enter a URL", target: self, action: #selector(selectAddressEntry))
            button.setContentHuggingPriority(.init(rawValue: 10), for: .horizontal)
            tbItem.view = button
            
        case .navigation:
            let back = NSImage(named: NSImage.touchBarGoBackTemplateName)!
            let forward = NSImage(named: NSImage.touchBarGoForwardTemplateName)!
            
            let segmentedControl = NSSegmentedControl(images: [ back, forward ], trackingMode: .momentary, target: self, action: #selector(navigationClicked(_:)))
            tbItem.view = segmentedControl
            
        case .sharingPicker:
            let picker = NSSharingServicePickerTouchBarItem(identifier: identifier)
            picker.delegate = self
            return picker
            
        case .adjustRows:
            let label = NSTextField()
            label.isBordered = false
            label.isEditable = false
            label.backgroundColor = .clear
            label.stringValue = "Rows:"
            label.font = .boldSystemFont(ofSize: 20)
            
            let add = NSImage(named: NSImage.touchBarAddTemplateName)!
            let remove = NSImage(named: NSImage.touchBarRemoveTemplateName)!
            let control = NSSegmentedControl(images: [ add, remove ], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustRows(_:)))
            
            let stack = NSStackView(views: [ label, control ])
            stack.spacing = 10
            
            tbItem.customizationLabel = "Rows"
            tbItem.view = stack
            
        case .adjustCols:
            let label = NSTextField()
            label.isBordered = false
            label.isEditable = false
            label.backgroundColor = .clear
            label.stringValue = "Cols:"
            label.font = .boldSystemFont(ofSize: 20)
            
            let add = NSImage(named: NSImage.touchBarAddTemplateName)!
            let remove = NSImage(named: NSImage.touchBarRemoveTemplateName)!
            let control = NSSegmentedControl(images: [ add, remove ], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustColumns(_:)))
            
            let stack = NSStackView(views: [ label, control ])
            stack.spacing = 10
            
            tbItem.customizationLabel = "Columns"
            tbItem.view = stack
            
        case .adjustGrid:
            let popover = NSPopoverTouchBarItem(identifier: identifier)
            popover.collapsedRepresentationLabel = "Grid"
            popover.customizationLabel = "Adjust Grid"
            popover.popoverTouchBar = NSTouchBar()
            popover.popoverTouchBar.delegate = self
            popover.popoverTouchBar.defaultItemIdentifiers = [ .adjustRows, .fixedSpaceLarge, .adjustCols ]
            return popover
            
        default:
            return nil
        }
        
        return tbItem
    }
    
    
    @objc func selectAddressEntry() {
        if let windowController = viewController.view.window?.windowController as? WindowController {
            windowController.window?.makeFirstResponder(windowController.addressEntry)
        }
    }
    
    @objc func navigationClicked(_ sender: NSSegmentedControl) {
        viewController.navigationClicked(sender)
    }
    
    @objc func adjustRows(_ sender: NSSegmentedControl) {
        viewController.adjustRows(sender)
    }
    
    @objc func adjustColumns(_ sender: NSSegmentedControl) {
        viewController.adjustColumns(sender)
    }
}


extension ViewControllerTouchbarManager: NSSharingServicePickerTouchBarItemDelegate {
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        guard let webView = viewController.selectedWebView else { return [ ] }
        guard let url = webView.url?.absoluteString else { return [ ] }
        return [ url ]
    }
}

