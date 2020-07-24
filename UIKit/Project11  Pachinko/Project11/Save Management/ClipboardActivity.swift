//
//  ClipboardActivity.swift
//  Project11
//
//  Created by Jakub Charvat on 29/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ClipboardActivity: UIActivity {
    
    private var items: [Any] = []
    
    override var activityType: UIActivity.ActivityType? { nil }
    override var activityTitle: String? { "Copy raw JSON to Clipboard" }
    override var activityImage: UIImage? { UIImage(systemName: "doc.on.doc") }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        items = activityItems
    }
    
    override func perform() {
        guard let url = items.first as? URL else { return }
        guard let jsonString = try? String(contentsOf: url) else { return }
        
        UIPasteboard.general.string = jsonString
    }
    
    override class var activityCategory: UIActivity.Category { .action }
}
