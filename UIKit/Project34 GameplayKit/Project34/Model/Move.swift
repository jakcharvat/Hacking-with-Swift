//
//  Move.swift
//  Project34
//
//  Created by Jakub Charvat on 16/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
}
