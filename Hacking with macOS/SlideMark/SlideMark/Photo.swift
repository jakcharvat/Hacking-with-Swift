//
//  Photo.swift
//  SlideMark
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class Photo: NSCollectionViewItem {
    
    let selectedBorderWidth: CGFloat = 3
    
    override var isSelected: Bool {
        didSet {
            isSelected ? highlight() : unhighlight()
        }
    }
    
    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            hightlightStateDidChange()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.systemBlue.cgColor
    }
    
    
    private func hightlightStateDidChange() {
        switch highlightState {
        case .forSelection:
            highlight()
            
        case .forDeselection:
            unhighlight()
            
        default:
            isSelected ? highlight() : unhighlight()
        }
        
        
    }
    
    private func highlight() {
        view.layer?.borderWidth = selectedBorderWidth
    }
    
    private func unhighlight() {
        view.layer?.borderWidth = 0
    }
    
}
