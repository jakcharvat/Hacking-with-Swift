//
//  GameScene.swift
//  Project11
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private let isEditingAvailable = true
    
    private let dropAreaCount = 4
    private let tappableAreaHeight: CGFloat = 200
    private let padding: CGFloat = 20
    
    private let ballColors = ["Blue", "Yellow", "Purple", "Grey", "Red", "Cyan", "Green"]
    
    private var scoreLabel: SKLabelNode!
    private(set) var score = 0 {
        didSet {
            if score < 0 { score = 0 }
            
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private(set) var saveLabel: SKLabelNode!
    private var separator: SKLabelNode!
    
    private var editLabel: SKLabelNode!
    private var editingEnabled = false {
        didSet {
            editLabel.text = editingEnabled ? "Quit Editing" : "Edit"
            saveLabel.isHidden = !editingEnabled
            separator.isHidden = !editingEnabled
        }
    }
    
    private(set) var openLabel: SKLabelNode!
    
    private var ballsLabel: SKLabelNode!
    private(set) var ballsAvailable = 5 {
        didSet {
            ballsLabel.text = "\(ballsAvailable) Balls Left"
        }
    }
    
    override func didMove(to view: SKView) {
        configureBackground()
        configurePhysics()
        configureBouncers()
        configureDropAreas()
        configureUI()
    }
    
    private func configureBackground() {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    private func configurePhysics() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
    }
    
    private func configureBouncers() {
        let strideMin = frame.minX
        let strideMax = frame.maxX
        let strideAmt = (frame.maxX - frame.minX) / CGFloat(dropAreaCount)
        
        for x in stride(from: strideMin, through: strideMax, by: strideAmt) {
            createBouncer(at: CGPoint(x: x, y: 0))
        }
    }
    
    private func configureDropAreas() {
        let strideAmt = (frame.maxX - frame.minX) / CGFloat(dropAreaCount)
        let strideMin = frame.minX + (strideAmt / 2)
        let strideMax = frame.maxX - (strideAmt / 2)
        
        var isGood = true
        for x in stride(from: strideMin, through: strideMax, by: strideAmt) {
            createDropArea(at: CGPoint(x: x, y: 0), isGood: isGood)
            isGood.toggle()
        }
    }
    
    private func configureUI() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: frame.maxX - padding, y: frame.maxY - padding)
        addChild(scoreLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "\(ballsAvailable) Balls Left"
        ballsLabel.fontSize = 20
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.verticalAlignmentMode = .top
        ballsLabel.position = CGPoint(x: frame.maxX - padding,
                                      y: scoreLabel.position.y - scoreLabel.fontSize - padding / 2)
        addChild(ballsLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: padding, y: frame.maxY - padding)
        editLabel.horizontalAlignmentMode = .left
        editLabel.verticalAlignmentMode = .top
        if isEditingAvailable {
            addChild(editLabel)
        }
        
        saveLabel = SKLabelNode(fontNamed: "Chalkduster")
        saveLabel.text = "Export Level"
        saveLabel.position = CGPoint(x: padding, y: editLabel.position.y - editLabel.fontSize - padding)
        saveLabel.horizontalAlignmentMode = .left
        saveLabel.verticalAlignmentMode = .top
        saveLabel.isHidden = true
        if isEditingAvailable {
            addChild(saveLabel)
        }
        
        let separation = editLabel.position.y  - editLabel.fontSize - saveLabel.position.y
        separator = SKLabelNode(fontNamed: "Chalkduster")
        separator.text = "-----"
        separator.position = CGPoint(x: padding, y: saveLabel.position.y + separation / 2 - 4)
        separator.horizontalAlignmentMode = .left
        separator.verticalAlignmentMode = .center
        separator.isHidden = true
        if isEditingAvailable {
            addChild(separator)
        }
        
        openLabel = SKLabelNode(fontNamed: "Chalkduster")
        openLabel.text = "Open Level"
        openLabel.fontSize = 20
        openLabel.position = CGPoint(x: frame.midX, y: frame.maxY - padding)
        openLabel.verticalAlignmentMode = .top
        openLabel.horizontalAlignmentMode = .center
        addChild(openLabel)
    }
    
    private func createBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    private func createDropArea(at position: CGPoint, isGood: Bool) {
        let goodOrBad = isGood ? "Good" : "Bad"
        
        let dropArea = SKSpriteNode(imageNamed: "slotBase\(goodOrBad)")
        let dropGlow = SKSpriteNode(imageNamed: "slotGlow\(goodOrBad)")
        
        dropArea.position = position
        dropGlow.position = position
        
        dropArea.name = goodOrBad.lowercased()
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        dropGlow.run(spinForever)
        
        dropArea.physicsBody = SKPhysicsBody(rectangleOf: dropArea.size)
        dropArea.physicsBody?.isDynamic = false
        
        addChild(dropArea)
        addChild(dropGlow)
    }
    
    
    func resetGame() {
        score = 0
        ballsAvailable = 5
        for child in children {
            if child.name == "box" { child.removeFromParent() }
            if child.name == "ball" { child.removeFromParent() }
            editingEnabled = false
        }
    }
    
}
    
    
//MARK: - Touches
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            
            showTouch(at: location)
            
            if objects.contains(editLabel) {
                editingEnabled.toggle()
                return
            }
            
            if objects.contains(saveLabel) {
                saveLevel()
                return
            }
            
            if objects.contains(openLabel) {
                openLevel()
                return
            }
            
            if let touchedBox = objects.first(where: { $0.name == "box" })  {
                touchedBox.removeFromParent()
                return
            }
            
            if editingEnabled {
                createBox(at: location)
            } else {
                createBall(at: location)
            }
        }
    }
    
    private func createBall(at location: CGPoint) {
        
        guard location.y >= frame.maxY - tappableAreaHeight, ballsAvailable > 0 else { return }
        
        let ball = SKSpriteNode(imageNamed: "ball\(ballColors.randomElement()!)")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody?.restitution = 0.4
        ball.position = location
        ball.name = "ball"
        addChild(ball)
        
        ballsAvailable -= 1
    }
    
    func createBox(at location: CGPoint, size: CGSize? = nil, color: UIColor? = nil, rotation: CGFloat? = nil) {
        let size = size ?? CGSize(width: .random(in: 16...128), height: 16)
        let color = color ?? UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
        let box = SKSpriteNode(color: color, size: size)
        box.zRotation = rotation ?? .random(in: 0...3)
        box.position = location
        box.name = "box"
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        
        addChild(box)
    }
    
    private func showTouch(at location: CGPoint) {
        let touch = SKShapeNode(circleOfRadius: 22)
        touch.fillColor = UIColor.white.withAlphaComponent(0.6)
        touch.position = location
        touch.setScale(0.8)
        addChild(touch)
        
        let appear = SKAction.group([
            SKAction.scale(to: 1, duration: 0.2),
            SKAction.fadeIn(withDuration: 0.2)
        ])
        let disappear = SKAction.group([
            SKAction.scale(to: 0.4, duration: 0.4),
            SKAction.fadeOut(withDuration: 0.4)
        ])
        let sequence = SKAction.sequence([
            appear,
            SKAction.wait(forDuration: 0.4),
            disappear,
            SKAction.removeFromParent()
        ])
        
        touch.run(sequence)
    }
}


//MARK: - Collisions
extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            guard let ball = nodeA as? SKSpriteNode else { return }
            collisionBetween(ball: ball, object: nodeB)
        } else if nodeB.name == "ball" {
            guard let ball = nodeB as? SKSpriteNode else { return }
            collisionBetween(ball: ball, object: nodeA)
        }
    }
    
    
    private func collisionBetween(ball: SKSpriteNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball)
            ballsAvailable += 1
        } else if object.name == "bad" {
            destroy(ball)
        } else if object.name == "box" {
            guard let box = object as? SKSpriteNode else { return }
            destroy(box)
            score += 1
        }
    }
    
    private func destroy(_ ball: SKSpriteNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = CGPoint(x: ball.position.x, y: ball.position.y - ball.size.height / 2)
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
}
