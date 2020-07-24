//
//  GameScene.swift
//  Project26
//
//  Created by Jakub Charvat on 12/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    let levels = 2
    var currentLevel = 1 {
        didSet {
            if currentLevel > levels { currentLevel = 1 }
        }
    }
    
    lazy var levelManager: LevelManager = { LevelManager(scene: self) }()
    var motionManager: CMMotionManager!
    
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isGameOver = false
    var portals: [Portal]?
    var stopPortals = false
    
    var lastTouchPosition: CGPoint?
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        loadBackground()
        levelManager.loadLevel(from: "level\(currentLevel)")
        player = levelManager.createPlayer()
        scoreLabel = levelManager.createScoreLabel()
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        guard !isGameOver else { return }
        
        #if targetEnvironment(simulator)
        if let touch = lastTouchPosition {
            let diff = touch - player.position
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }
}


//MARK: - Background
extension GameScene {
    func loadBackground() {
        let node = SKSpriteNode(imageNamed: "background")
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.blendMode = .replace
        node.zPosition = -1
        node.name = "dontClear"
        addChild(node)
    }
}


//MARK: - Simulator Hack - Touches
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        lastTouchPosition = position
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: self)
        lastTouchPosition = position
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
}


//MARK: - Physics Contact
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        switch node.name {
        case "vortex":
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.player = self?.levelManager.createPlayer()
                self?.isGameOver = false
            }
            
        case "star":
            node.removeFromParent()
            score += 1
            
        case "finish":
            isGameOver = true
            nextLevel()
            
        case "portal":
            guard !stopPortals else { return }
            stopPortals = true
            
            guard let portals = portals, portals.count == 2 else { return }
            guard let node = node as? SKSpriteNode else { return }
            guard let origin = portals.first(where: { $0.node == node }) else { return }
            guard let destination = origin.link else { return }
            
            isGameOver = true
            stopPlayer { [weak self] in
                guard let self = self else { return }
                self.player.removeFromParent()
                self.player = self.levelManager.createPlayer(at: destination.position)
                self.player.alpha = 0
                self.player.setScale(0.1)
                self.player.run(.group([.fadeIn(withDuration: 0.3), .scale(to: 1, duration: 0.3)])) { [weak self] in
                    self?.isGameOver = false
                }
            }
            
        default:
            break
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player && nodeB.name == "portal" {
            portalContactEnd()
        }
        
        if nodeB == player && nodeA.name == "portal" {
            portalContactEnd()
        }
    }
    
    func portalContactEnd() {
        stopPortals = false
    }
}


//MARK: - Stopping the player
extension GameScene {
    func stopPlayer(then callback: @escaping () -> ()) {
        if let velocity = player.physicsBody?.velocity {
            physicsWorld.gravity = .zero
            player.physicsBody?.linearDamping = sqrt(velocity.dx ** 2 + velocity.dy ** 2) / 50
            player.run(.group([.fadeOut(withDuration: 0.3), .scale(to: 0.1, duration: 0.3)]), completion: callback)
        }
    }
}


//MARK: - Next Level
extension GameScene {
    func nextLevel() {
        stopPlayer { [weak self] in
            self?.fadeOut()
        }
    }
    
    func fadeOut() {
        let textNode = SKSpriteNode(imageNamed: "nextlevel")
        textNode.position = CGPoint(x: frame.midX, y: frame.midY)
        textNode.zPosition = 5
        textNode.alpha = 0
        textNode.name = "dontClear"
        textNode.setScale(0.1)
        
        let overlay = SKShapeNode(rect: frame)
        overlay.zPosition = 4
        overlay.fillColor = .black
        overlay.alpha = 0
        overlay.name = "dontClear"
        overlay.lineWidth = 0
        
        
        let fadeAction = SKAction.sequence([.fadeIn(withDuration: 0.5), .wait(forDuration: 1), .fadeOut(withDuration: 0.5)])
        let scaleAction = SKAction.scale(to: 2, duration: 2)
        scaleAction.timingFunction = { (time) -> Float in
            let t = 2 * time - 1
            let progress = 0.4 * (t ** 3) + 0.1 * t + 0.5
            return progress
        }
        
        let groupAction = SKAction.group([fadeAction, scaleAction])
        
        addChild(textNode)
        addChild(overlay)
        
        textNode.run(groupAction) { textNode.removeFromParent() }
        overlay.run(.group([fadeAction, .sequence([
            .wait(forDuration: 0.5),
            .run { [weak self] in
                guard let self = self else { return }
                
                self.levelManager.clear()
                
                self.currentLevel += 1
                self.score = 0
                
                self.levelManager.loadLevel(from: "level\(self.currentLevel)")
                self.player = self.levelManager.createPlayer()
            }
        ])])) { [weak self] in
            overlay.removeFromParent()
            self?.isGameOver = false
        }
    }
}
