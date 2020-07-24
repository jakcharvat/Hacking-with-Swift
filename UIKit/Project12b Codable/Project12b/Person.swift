//
//  Person.swift
//  Project12b
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

struct Person: Codable {
    var name: String
    let image: String
    
    mutating func rename(to name: String) {
        self.name = name
    }
}
