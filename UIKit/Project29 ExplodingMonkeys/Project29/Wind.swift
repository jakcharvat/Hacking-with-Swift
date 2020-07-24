//
//  Wind.swift
//  Project29
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Wind {
    let direction: WindDirection
    let speed: Int
    
    static func random() -> Wind { Wind(direction: .random(), speed: .random(in: 0...20)) }
    
    enum WindDirection: Int {
        case left = -1, right = 1
        
        static func random() -> WindDirection {
            if Bool.random() {
                return WindDirection.left
            } else {
                return WindDirection.right
            }
        }
    }
}
