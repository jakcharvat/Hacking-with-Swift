//
//  GameScene.swift
//  Project17
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let possibleEnemies = ["ball", "hammer", "tv"]
    private var isGameOver = false
    private var gameTimer: Timer?
    private var timerInterval = 1.0
    private var enemyCount = 0
    
    private var starField: SKEmitterNode!
    private var player: SKSpriteNode!
    
    private var scoreLabel: SKLabelNode!
    private var score = 0.0 {
        didSet {
            scoreLabel.text = "Score: \(String(format: "%.0f", score))"
        }
    }
    
    private var dragging = false
    
    private var lastTime: TimeInterval?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        starField.zPosition = -1
        addChild(starField)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: createEnemy(_:))
    }
    
    
    func createEnemy(_: Timer) {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        sprite.name = "enemy"
        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        enemyCount += 1
        
        if enemyCount >= 20 {
            timerInterval -= 0.1
            
            if timerInterval < 0.3 { timerInterval = 0.3 }
            
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: createEnemy(_:))
            enemyCount = 0
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            guard node.name == "enemy" else { continue }
            
            if node.position.x < 0 && !frame.intersects(node.frame) {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            if lastTime != nil {
                let delta = currentTime - lastTime!
                score += 1 * delta * 10
            }
            
            lastTime = currentTime
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if !dragging {
            let touchedNodes = nodes(at: location)
            guard touchedNodes.contains(player) else { return }
        }
        
        dragging = true
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragging = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
        
        starField.run(SKAction.sequence([
            .wait(forDuration: 2),
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ]))
    }
}
