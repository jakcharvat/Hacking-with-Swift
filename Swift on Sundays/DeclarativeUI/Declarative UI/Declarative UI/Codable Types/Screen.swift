//
//  Screen.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Screen: Decodable {
    let id: String
    let title: String
    let type: String
    let rows: [Row]
    let rightButton: Button?
}
