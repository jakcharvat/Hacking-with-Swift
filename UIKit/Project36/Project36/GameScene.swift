//
//  GameScene.swift
//  Project36
//
//  Created by Jakub Charvat on 17/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    var backgroundMusic: SKAudioNode!
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    
    var gameState = GameState.intro
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet { scoreLabel.text = "Score: \(score)" }
    }
    
    let rockTexture = SKTexture(imageNamed: "rock")
    var rockPhysics: SKPhysicsBody!
    let explosion = SKEmitterNode(fileNamed: "PlayerExplosion")
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        rockPhysics = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        
        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        createLogos()
        
        if let music = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: music)
            addChild(backgroundMusic)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .intro:
            gameState = .playing
            
            let fadeout = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.scheduleRockCreation()
            }
            
            let sequence = SKAction.sequence([ fadeout, wait, activatePlayer, remove ])
            logo.run(sequence)
            
        case .playing:
            player.physicsBody?.velocity = .zero
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            
        case .dead:
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                let transition = SKTransition.moveIn(with: .right, duration: 1)
                view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil, player.physicsBody != nil else { return }
        
        let rotation = player.physicsBody!.velocity.dy * 0.001
        let rotateAction = SKAction.rotate(toAngle: rotation, duration: 0.1)
        
        player.run(rotateAction)
    }
    
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody?.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        player.physicsBody?.collisionBitMask = 0
        
        addChild(player)
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        player.run(.repeatForever(.animate(with: [ playerTexture, frame2, frame3 ], timePerFrame: 0.01)))
    }
    
    
    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        topSky.position = CGPoint(x: frame.midX, y: frame.maxY)
        bottomSky.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(topSky)
        addChild(bottomSky)
        
        topSky.zPosition = -40
        bottomSky.zPosition = -40
    }
    
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = .zero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(i), y: 100)
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            
            background.run(.repeatForever(.sequence([ moveLeft, moveReset ])))
        }
    }
    
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: groundTexture.size().width / 2 + (groundTexture.size().width * CGFloat(i)), y: groundTexture.size().height / 2)
            
            ground.physicsBody = SKPhysicsBody(texture: groundTexture, size: groundTexture.size())
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            
            ground.run(.repeatForever(.sequence([ moveLeft, moveReset ])))
        }
    }
    
    
    func createRocks() {
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        topRock.physicsBody?.isDynamic = false
        topRock.zRotation = .pi
        topRock.xScale = -1
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        bottomRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody
        bottomRock.physicsBody?.isDynamic = false
        
        bottomRock.zPosition = -20
        topRock.zPosition = -20
        
        let rockCollision = SKSpriteNode(color: .red, size: CGSize(width: 32, height: frame.height))
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        let xPosition = frame.width + topRock.frame.width
        
        let max = frame.height / 3
        let yPosition = CGFloat.random(in: -50 ... max)
        
        let rockSpacing: CGFloat = 70
        
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockSpacing)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockSpacing)
        rockCollision.position = CGPoint(x: xPosition + rockCollision.size.width * 2, y: frame.midY)
        
        let positionDelta = frame.width + topRock.frame.width * 2
        
        let moveAction = SKAction.moveBy(x: -positionDelta, y: 0, duration: 6.2)
        let sequence = SKAction.sequence([ moveAction, .removeFromParent() ])
        
        topRock.run(sequence)
        bottomRock.run(sequence)
        rockCollision.run(sequence)
    }
    
    
    func scheduleRockCreation() {
        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }
        
        let sequence = SKAction.sequence([ create, .wait(forDuration: 3) ])
        run(.repeatForever(sequence))
    }
    
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.fontColor = .black
        score = 0
        
        addChild(scoreLabel)
    }
    
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
    
}


extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            run(.playSoundFileNamed("coin.wav", waitForCompletion: false))
            
            score += 1
            
            return
        }
        
        guard contact.bodyA.node != nil, contact.bodyB.node != nil else { return }
        
        if contact.bodyA.node == player || contact.bodyB.node == player {
            if let explosion = explosion, explosion.parent == nil {
                explosion.position = player.position
                explosion.zPosition = 10
                explosion.particleSize = CGSize(width: 64, height: 64)
                addChild(explosion)
                
                explosion.run(.sequence([ .wait(forDuration: 1.1), .removeFromParent() ]))
            }
            
            run(.playSoundFileNamed("explosion.wav", waitForCompletion: false))
            
            gameOver.alpha = 1
            gameState = .dead
            backgroundMusic.run(.stop())
            
            player.removeFromParent()
            speed = 0
        }
    }
}


enum GameState {
    case intro
    case playing
    case dead
}
