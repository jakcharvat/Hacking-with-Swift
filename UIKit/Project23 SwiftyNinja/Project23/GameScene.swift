//
//  GameScene.swift
//  Project23
//
//  Created by Jakub Charvat on 11/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    //MARK: Create Enemy Properties
    let enemyToBombRatio = 6
    let spawnXRange = 64...960
    let spawnY = -128
    let angularVelocityRange: ClosedRange<CGFloat> = -3...3
    let breakpoints: [CGFloat] = [256, 512, 768]
    let minXVelocityRange = 3...5
    let maxXVelocityRange = 8...15
    let yVelocityRange = 24...32
    let velocityMultiplier = 40
    
    //MARK: Properties
    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    var activeSlicePoints = [CGPoint]()
    
    var activeEnemies = [SKSpriteNode]()
    
    var isSwooshSoundActive = false
    var bombSoundEffect: AVAudioPlayer?
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
}


//MARK: - Lifecycle and UI
extension GameScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)

        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85

        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]
        
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !activeEnemies.contains(where: { $0.name == "bombContainer" }) {
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
        
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()

                    if node.name == "enemy" {
                        node.name = ""
                        subtractLife()

                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }

                nextSequenceQueued = true
            }
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)

        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }

    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)

            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2

        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3

        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9

        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5

        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
}


//MARK: - Touches
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isGameEnded {
            return
        }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" || node.name == "rocketPenguin" {
                let isRocketPenguin = node.name == "rocketPenguin"
                
                // Destroy the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                node.name = ""
                
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])

                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                score += isRocketPenguin ? 10 : 1
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
            } else {
                // Destroy bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }

                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }

                node.name = ""
                bombContainer.physicsBody?.isDynamic = false

                let scaleOut = SKAction.scale(to: 0.001, duration:0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut])

                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)

                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }

                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(.fadeOut(withDuration: 0.25))
        activeSliceFG.run(.fadeOut(withDuration: 0.25))
    }
}


//MARK: - Active Slice
extension GameScene {
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            let toRemove = activeSlicePoints.count - 12
            activeSlicePoints.removeFirst(toRemove)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
}


//MARK: - Swoosh Sound
extension GameScene {
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(soundAction) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
}


//MARK: - Create Enemy
extension GameScene {
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...enemyToBombRatio)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            // Create Bomb
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
        } else if enemyType == enemyToBombRatio {
            // Create Fast Penguin
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "rocketPenguin"
        } else {
            // Create Penguin
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // Position the enemy
        let randomPosition = CGPoint(x: .random(in: spawnXRange), y: spawnY)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: angularVelocityRange)
        let randomXVelocity: Int
        
        if randomPosition.x < breakpoints[0] {
            randomXVelocity = Int.random(in: maxXVelocityRange)
        } else if randomPosition.x < breakpoints[1] {
            randomXVelocity = Int.random(in: minXVelocityRange)
        } else if randomPosition.x < breakpoints[2] {
            randomXVelocity = -Int.random(in: minXVelocityRange)
        } else {
            randomXVelocity = -Int.random(in: maxXVelocityRange)
        }
        
        let randomYVelocity: Int
        if enemy.name == "rocketPenguin" {
            randomYVelocity = Int(Double(Int.random(in: yVelocityRange)) * 1.5)
        } else {
            randomYVelocity = Int.random(in: yVelocityRange)
        }
        
        enemy.physicsBody = SKPhysicsBody()
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * velocityMultiplier, dy: randomYVelocity * velocityMultiplier)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
}


//MARK: - Toss Enemies
extension GameScene {
    func tossEnemies() {
        
        if isGameEnded {
            return
        }
        
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            for i in [1.0, 2.0, 3.0, 4.0] {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * i)) { [weak self] in self?.createEnemy() }
            }
            
        case .fastChain:
            createEnemy()
            
            for i in [1.0, 2.0, 3.0, 4.0] {
                DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * i)) { [weak self] in self?.createEnemy() }
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}


//MARK: - Life Subtraction
extension GameScene {
    func subtractLife() {
        lives -= 1
        
        run(.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration:0.1))
    }
}


//MARK: - End Game
extension GameScene {
    func endGame(triggeredByBomb: Bool) {
        if isGameEnded {
            return
        }

        isGameEnded = true
        physicsWorld.speed = 0
        isUserInteractionEnabled = false

        bombSoundEffect?.stop()
        bombSoundEffect = nil

        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        let node = SKLabelNode(fontNamed: "Chalkduster")
        node.text = "GAME OVER"
        node.fontSize = 128
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        node.fontColor = .white
        node.verticalAlignmentMode = .center
        node.alpha = 0
        node.setScale(0.2)
        
        addChild(node)
        
        let inAction = SKAction.group([.fadeIn(withDuration: 0.25), .scale(to: 1, duration: 0.25)])
        let outAction = SKAction.group([.fadeAlpha(to: 0, duration: 0.25), .scale(to: 10, duration: 0.25)])
        
        inAction.timingMode = .easeOut
        outAction.timingMode = .easeIn
        
        node.run(.sequence([
            inAction,
            .wait(forDuration: 1),
            outAction,
            .removeFromParent()
        ]))
    }
}


//MARK: - Enums
enum ForceBomb {
    case never, always, random
}

enum SequenceType: Int, CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}
