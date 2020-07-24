//
//  Portal.swift
//  Project26
//
//  Created by Jakub Charvat on 12/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class Portal: CustomStringConvertible {
    let node: SKSpriteNode
    weak var link: SKSpriteNode?
    
    init(node: SKSpriteNode, link: SKSpriteNode? = nil) {
        self.node = node
        self.link = link
    }
    
    var description: String {
        return "Portal: \(node.name ?? "") <--> \(link?.name ?? "")"
    }
}
