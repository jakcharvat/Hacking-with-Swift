//
//  StarFormatter.swift
//  Bookworm
//
//  Created by Jakub Charvat on 17/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class StarFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        if let obj = obj, let number = Int(String(describing: obj)) {
            return String(repeating: "⭐️", count: number)
        }
        
        return ""
    }
}
