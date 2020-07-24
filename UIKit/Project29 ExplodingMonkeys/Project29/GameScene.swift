//
//  GameScene.swift
//  Project29
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController!
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
        
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if banana.position.y < -1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
}


//MARK: - Buildings Creation
extension GameScene {
    func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - size.width / 2, y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
            
        }
    }
}


//MARK: - Create Players
extension GameScene {
    
    func createPlayers() {
        player1 = createPlayer(1)
        player2 = createPlayer(2)
    }
    
    func createPlayer(_ number: Int) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player")
        player.name = "player\(number)"
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player.physicsBody?.isDynamic = false
        
        let buildingIndex: Int
        if number == 1 {
            buildingIndex = 1
        } else {
            buildingIndex = buildings.count - 2
        }
        
        let building = buildings[buildingIndex]
        let pos = CGPoint(x: building.position.x, y: building.position.y + (building.size.height + player.size.height) / 2)
        player.position = pos
        addChild(player)
        return player
        
    }
}


//MARK: - Launching
extension GameScene {
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10
        let rad = angle.degInRad
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        let bananaPosition: CGPoint
        let angularVelocity: CGFloat
        let player: SKSpriteNode
        let impulse: CGVector
        
        if currentPlayer == 1 {
            bananaPosition = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            angularVelocity = -20
            player = player1
            impulse = CGVector(dx: cos(rad) * speed, dy: sin(rad) * speed)
        } else {
            bananaPosition = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            angularVelocity = 20
            player = player2
            impulse = CGVector(dx: cos(rad) * -speed, dy: sin(rad) * speed)
        }
        
        banana.position = bananaPosition
        banana.physicsBody?.angularVelocity = angularVelocity
        
        let raiseArmAction = SKAction.setTexture(SKTexture(imageNamed: "player\(currentPlayer)Throw"))
        let lowerArmAction = SKAction.setTexture(SKTexture(imageNamed: "player"))
        let pauseAction = SKAction.wait(forDuration: 0.15)
        let sequence = SKAction.sequence([ raiseArmAction, pauseAction, lowerArmAction ])
        player.run(sequence)
        
        banana.physicsBody?.applyImpulse(impulse)
        
    }
}


//MARK: - Contact
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let bodies = [contact.bodyA, contact.bodyB].sorted { $0.categoryBitMask < $1.categoryBitMask }
        let firstBody = bodies.first
        let secondBody = bodies.last
        
        guard let firstNode = firstBody?.node,
            let secondNode = secondBody?.node else { return }
        
        if firstNode.name == "banana" {
            
            switch secondNode.name {
            case "building":
                bananaHit(building: secondNode, at: contact.contactPoint)
                
            case "player1":
                destroy(player: player1)
                
            case "player2":
                destroy(player: player2)
                
            default:
                break
            }
            
        }
    }
}

//MARK: - Destroy
extension GameScene {
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
            
            explosion.run(.sequence([ .wait(forDuration: 0.5), .removeFromParent() ]))
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            let player1Won = player.name == "player2"
            if player1Won {
                self.viewController.player1Score += 1
            } else {
                self.viewController.player2Score += 1
            }
            
            self.viewController.checkHasPlayerWon { [weak self] hasWon in
                guard let self = self else { return }
                
                if hasWon {
                    self.viewController.player1Score = 0
                    self.viewController.player2Score = 0
                    self.viewController.updateWind()
                }
                
                DispatchQueue.main.async {
                    self.changePlayer()
                    newGame.currentPlayer = self.currentPlayer
                    newGame.physicsWorld.gravity = self.physicsWorld.gravity
                    
                    let transition = SKTransition.doorway(withDuration: 1.5)
                    self.view?.presentScene(newGame, transition: transition)
                }
            }
        }
    }
}


//MARK: - Hit Building
extension GameScene {
    func bananaHit(building: SKNode, at contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingContactPoint = convert(contactPoint, to: building)
        building.hit(at: buildingContactPoint)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
            
            explosion.run(.sequence([ .wait(forDuration: 0.5), .removeFromParent() ]))
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
}


//MARK: - Change Active Player
extension GameScene {
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(currentPlayer)
    }
}


//MARK: - Enums
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}


//MARK: - Angle Conversions
extension Int {
    var degInRad: Double { Double(self) / 180 * .pi }
}
