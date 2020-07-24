//
//  ViewControllerTouchbarDelegate.swift
//  GridBrowser
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import AppKit

class ViewControllerTouchbarManager: NSObject, NSTouchBarDelegate {
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        default:
            return nil
        }
    }
    
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
}
