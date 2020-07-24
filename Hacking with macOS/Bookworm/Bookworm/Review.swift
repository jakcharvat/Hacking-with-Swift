//
//  Review.swift
//  Bookworm
//
//  Created by Jakub Charvat on 17/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class Review: NSObject {
    @objc var title = "Enter the title"
    @objc var author = "Enter the author"
    @objc var rating = 0
    @objc var text = NSAttributedString()
}
