//
//  GameScene.swift
//  BubbleTrouble
//
//  Created by Jakub Charvat on 04/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var bubbleTextures = [SKTexture]()
    var currentBubbleTexture = 0
    var maximumNumber = 1
    var bubbles = [SKSpriteNode]()
    var bubbleTimer: Timer!
    
    override func didMove(to view: SKView) {
        bubbleTextures.append(SKTexture(imageNamed: "bubbleBlue"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleCyan"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleGray"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleGreen"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleOrange"))
        bubbleTextures.append(SKTexture(imageNamed: "bubblePink"))
        bubbleTextures.append(SKTexture(imageNamed: "bubblePurple"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleRed"))
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = .zero
        
        for _ in 1...8 { createBubble() }
        
        bubbleTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: createBubble(timer:))
    }
    
    
    private func createBubble(timer: Timer? = nil) {
        let bubble = SKSpriteNode(texture: bubbleTextures[currentBubbleTexture])
        bubble.name = "\(maximumNumber)"
        bubble.zPosition = 1
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        label.text = bubble.name
        label.color = .white
        label.fontSize = 64
        
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        
        bubble.addChild(label)
        addChild(bubble)
        
        bubbles.append(bubble)
        
        let xPos = Int.random(in: 0 ..< 800)
        let yPos = Int.random(in: 0 ..< 600)
        
        bubble.position = CGPoint(x: xPos, y: yPos)
        
        bubble.setScale(.random(in: 0.7...1))
        bubble.alpha = 0
        
        bubble.run(.fadeIn(withDuration: 0.5))
        
        configurePhysics(for: bubble)
        nextBubble()
    }
    
    private func configurePhysics(for bubble: SKSpriteNode) {
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2)
        bubble.physicsBody?.linearDamping = 0
        bubble.physicsBody?.angularDamping = 0
        bubble.physicsBody?.restitution = 1
        bubble.physicsBody?.friction = 0
        
        let motionX = CGFloat.random(in: -200...200)
        let motionY = CGFloat.random(in: -200...200)
        let motion = CGVector(dx: motionX, dy: motionY)
        bubble.physicsBody?.velocity = motion
        bubble.physicsBody?.angularVelocity = .random(in: 0...1)
    }
    
    private func nextBubble() {
        currentBubbleTexture += 1
        if currentBubbleTexture >= bubbleTextures.count { currentBubbleTexture = 0 }
        
        maximumNumber += .random(in: 1...3)
        
        let maxNumberString = "\(maximumNumber)"
        if [ "6", "9" ].contains(maxNumberString.last!) {
            maximumNumber += 1
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let clickedNodes = nodes(at: location).filter { $0.name != nil }
        guard clickedNodes.count > 0 else { return }
        
        let lowestBubbleOnScreen = bubbles.min { Int($0.name!)! < Int($1.name!)! }
        guard let targetBubble = lowestBubbleOnScreen?.name else { return }
        
        for node in clickedNodes {
            if node.name == targetBubble {
                pop(node as! SKSpriteNode)
                return
            }
        }
        
        createBubble()
        createBubble()
        
    }
    
    private func pop(_ node: SKSpriteNode) {
        guard let index = bubbles.firstIndex(of: node) else { return }
        bubbles.remove(at: index)
        
        node.physicsBody = nil
        node.name = nil
        
        let group = SKAction.group([ .fadeOut(withDuration: 0.3), .scale(by: 1.5, duration: 0.3) ])
        let sequence = SKAction.sequence([ group, .removeFromParent() ])
        node.run(sequence)
        
        run(.playSoundFileNamed("pop.wav", waitForCompletion: false))
        
        if bubbles.isEmpty {
            bubbleTimer.invalidate()
            
            let gameOver = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            gameOver.text = "You Won!"
            gameOver.fontSize = 64
            gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
            gameOver.verticalAlignmentMode = .center
            gameOver.horizontalAlignmentMode = .center
            gameOver.setScale(0.8)
            gameOver.alpha = 0
            addChild(gameOver)
            
            let entry = SKAction.group([ .fadeIn(withDuration: 0.3), .scale(to: 1, duration: 0.3) ])
            entry.timingMode = .easeOut
            let exit = SKAction.group([ .fadeOut(withDuration: 0.3), .scale(by: 1.5, duration: 0.3) ])
            exit.timingMode = .easeIn
            
            gameOver.run(.sequence([
                .wait(forDuration: 0.5),
                entry,
                .wait(forDuration: 1),
                exit
            ]))
        }
    }
}
