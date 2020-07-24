//
//  Extensions.swift
//  SlideMark
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

//MARK: - Array
extension Array {
    mutating func moveItem(from: Int, to: Int) {
        let item = self[from]
        self.remove(at: from)
        
        if to <= from {
            self.insert(item, at: to)
        } else {
            self.insert(item, at: to - 1)
        }
    }
}
