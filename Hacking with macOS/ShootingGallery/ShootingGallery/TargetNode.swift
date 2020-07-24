//
//  TargetNode.swift
//  ShootingGallery
//
//  Created by Jakub Charvat on 14/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class TargetNode: SKNode {
    var target: SKSpriteNode!
    var stick: SKSpriteNode!
    
    var level: Int = 0
    
    func setup() {
        let stickType = Int.random(in: 0...2)
        let targetType = Int.random(in: 0...3)
        
        stick = SKSpriteNode(imageNamed: "stick\(stickType)")
        target = SKSpriteNode(imageNamed: "target\(targetType)")
        
        target.name = "Target"
        target.position.y += 116
        
        addChild(stick)
        addChild(target)
    }
    
    
    func hit() {
        removeAllActions()
        target.name = nil
        
        let animationTime = 0.2
        target.run(.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        stick.run(.colorize(with: .black, colorBlendFactor: 1, duration: animationTime))
        run(SKAction.fadeOut(withDuration: animationTime))
        run(SKAction.moveBy(x: 0, y: -30, duration: animationTime))
        run(SKAction.scaleX(by: 0.8, y: 0.7, duration: animationTime))
    }
}
