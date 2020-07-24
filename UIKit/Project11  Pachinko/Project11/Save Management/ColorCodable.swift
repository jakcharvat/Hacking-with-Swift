//
//  ColorCodable.swift
//  Project11
//
//  Created by Jakub Charvat on 29/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

struct ColorCodable: Codable {
        
    private let r: CGFloat
    private let g: CGFloat
    private let b: CGFloat
    private let a: CGFloat
    
    init(from color: UIColor) {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    var uiColor: UIColor {
        UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
