//
//  SaveBox.swift
//  Project11
//
//  Created by Jakub Charvat on 29/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

struct SaveBox: Codable {
    let position: CGPoint
    let size: CGSize
    let color: ColorCodable
    let rotation: CGFloat
}
