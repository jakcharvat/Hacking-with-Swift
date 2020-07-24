//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Jakub Charvat on 05/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var bulletsSprite: SKSpriteNode!
    let bulletTextures = [
        SKTexture(imageNamed: "shots0"),
        SKTexture(imageNamed: "shots1"),
        SKTexture(imageNamed: "shots2"),
        SKTexture(imageNamed: "shots3"),
    ]
    var bulletsInClip = 3 {
        didSet { bulletsSprite.texture = bulletTextures[bulletsInClip] }
    }
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    
    var targetSpeed = 4.0
    var targetDelay = 0.8
    var targetCount = 0
    
    var isGameOver = false
    
    
    override func didMove(to view: SKView) {
        createBackground()
        createWater()
        createOverlay()
        createTarget()
    }
}


//MARK: - Background
extension GameScene {
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: 400, y: 300)
        background.blendMode = .replace
        addChild(background)
        
        let grass = SKSpriteNode(imageNamed: "grass-trees")
        grass.position = CGPoint(x: 400, y: 300)
        addChild(grass)
        grass.zPosition = 100
    }
}


//MARK: - Water
extension GameScene {
    func createWater() {
        func animate(_ node: SKNode, distance: CGFloat, duration: TimeInterval) {
            let moveUp = SKAction.moveBy(x: 0, y: distance, duration: duration)
            let moveDown = moveUp.reversed()
            let repeatForever = SKAction.repeatForever(.sequence([ moveUp, moveDown ]))
            node.run(repeatForever)
        }
        
        let waterBackground = SKSpriteNode(imageNamed: "water-bg")
        waterBackground.position = CGPoint(x: 400, y: 180)
        waterBackground.zPosition = 200
        addChild(waterBackground)
        
        let waterForeground = SKSpriteNode(imageNamed: "water-fg")
        waterForeground.position = CGPoint(x: 400, y: 120)
        waterForeground.zPosition = 300
        addChild(waterForeground)

        animate(waterBackground, distance: 8, duration: 1.3)
        animate(waterForeground, distance: 12, duration: 1)
    }
}


//MARK: - GameScene overlay
extension GameScene {
    func createOverlay() {
        let curtains = SKSpriteNode(imageNamed: "curtains")
        curtains.position = CGPoint(x: 400, y: 300)
        curtains.zPosition = 400
        addChild(curtains)
        
        bulletsSprite = SKSpriteNode(imageNamed: "shots3")
        bulletsSprite.position = CGPoint(x: 170, y: 60)
        bulletsSprite.zPosition = 500
        addChild(bulletsSprite)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 680, y: 50)
        scoreLabel.zPosition = 500
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }
}


//MARK: - Target Creation
extension GameScene {
    func createTarget() {
        let target = TargetNode()
        target.setup()
        
        let level = Int.random(in: 0...2)
        target.level = level
        
        var movingRight = true
        
        switch level {
        case 0:
            // In front of the grass
            target.zPosition = 150
            target.position.y = 280
            target.setScale(0.7)
            
        case 1:
            // In front of the water bg
            target.zPosition = 250
            target.position.y = 190
            target.setScale(0.85)
            movingRight = false
            
        default:
            // In front of the water fg
            target.zPosition = 350
            target.position.y = 100
        }
        
        let move: SKAction
        
        if movingRight {
            target.position.x = 0
            move = SKAction.moveTo(x: 800, duration: targetSpeed)
        } else {
            target.position.x = 800
            move = SKAction.moveTo(x: 0, duration: targetSpeed)
            target.xScale *= -1
        }
        
        let shouldMoveUp = .random(in: 1...5) == 1
        
        let sequence: SKAction
        if shouldMoveUp {
            target.level = -5
            
            let moveUp = SKAction.moveBy(x: 0, y: 80, duration: targetSpeed)
            sequence = SKAction.sequence([ .group([ moveUp, move ]), .removeFromParent() ])
        } else {
            sequence = SKAction.sequence([ move, .removeFromParent() ])
        }
        
        target.run(sequence)
        addChild(target)
        
        levelUp()
    }
}


//MARK: - Leveling up
extension GameScene {
    func levelUp() {
        targetSpeed *= 0.99
        targetDelay *= 0.99
        
        targetCount += 1
        
        if targetCount < 100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + targetDelay) { [unowned self] in
                self.createTarget()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
                self.gameOver()
            }
        }
    }
}


//MARK: - Mouse Down
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        if isGameOver {
            if let newGame = SKScene(fileNamed: "GameScene") {
                let transition = SKTransition.doorway(withDuration: 1)
                view?.presentScene(newGame, transition: transition)
            }
            
            return
        }
        
        if bulletsInClip <= 0 {
            run(.playSoundFileNamed("empty.wav", waitForCompletion: false))
            return
        }
        
        run(.playSoundFileNamed("shot.wav", waitForCompletion: false))
        bulletsInClip -= 1
        
        let location = event.location(in: self)
        shoot(at: location)
    }
}


//MARK: - Shoot
extension GameScene {
    func shoot(at location: CGPoint) {
        let hitNodes = nodes(at: location).filter { $0.name == "Target" }
        guard let hitNode = hitNodes.first else { return }
        guard let parentNode = hitNode.parent as? TargetNode else { return }
        
        score += 5 - parentNode.level
        parentNode.hit()
    }
}


//MARK: - Key Down
extension GameScene {
    override func keyDown(with event: NSEvent) {
        guard !isGameOver else { return }
        
        if event.charactersIgnoringModifiers == " " {
            run(.playSoundFileNamed("reload.wav", waitForCompletion: false))
            bulletsInClip = 3
            score -= 1
        }
    }
}


//MARK: - Game over
extension GameScene {
    func gameOver() {
        isGameOver = true
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: 400, y: 300)
        gameOverTitle.setScale(2)
        gameOverTitle.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 1, duration: 0.3)
        let group = SKAction.group([ fadeIn, scaleDown ])
        
        gameOverTitle.run(group)
        gameOverTitle.zPosition = 999
        addChild(gameOverTitle)
    }
}
