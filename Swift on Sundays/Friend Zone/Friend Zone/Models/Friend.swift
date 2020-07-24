//
//  Friend.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Friend: Codable {
    var name: String = "New Friend"
    var timezone: TimeZone = .current
}
