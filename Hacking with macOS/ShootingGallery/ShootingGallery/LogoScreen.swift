//
//  LogoScreen.swift
//  ShootingGallery
//
//  Created by Jakub Charvat on 14/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class LogoScreen: SKScene {
    override func mouseDown(with event: NSEvent) {
        if let gameScene = SKScene(fileNamed: "GameScene") {
            let transition = SKTransition.doorway(withDuration: 1)
            view?.presentScene(gameScene, transition: transition)
        }
    }
}
