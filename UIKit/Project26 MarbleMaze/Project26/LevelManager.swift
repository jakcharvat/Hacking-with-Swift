//
//  LevelManager.swift
//  Project26
//
//  Created by Jakub Charvat on 12/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class LevelManager {
    weak var scene: GameScene?
    
    private var portals = [Portal]()
    
    private let blockWidth = 64
    private let blockHeight = 64
    
    init(scene: GameScene) {
        self.scene = scene
    }
}


//MARK: - Load level
extension LevelManager {
    func loadLevel(from fileName: String, withExtension fileExtension: String = "txt") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            fatalError("Couldn't find \(fileName).\(fileExtension) in bundle!")
        }
        
        guard let string = try? String(contentsOf: url) else {
            fatalError("Couldn't load \(fileName).\(fileExtension) from bundle!")
        }
        
        portals = []
        
        let lines = string.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        
        for (row, line) in lines.reversed().enumerated() {
            for (col, letter) in line.enumerated() {
                let position = CGPoint(x: (blockWidth * col) + blockWidth / 2, y: (blockHeight * row) + blockHeight / 2)
                guard let blockType = BlockType(rawValue: letter) else { fatalError("Unknown block type: \(letter)") }
                
                loadBlock(of: blockType, at: position)
            }
        }
        
        if portals.count == 2 {
            scene?.portals = portals
        }
        
    }
    
    private func loadBlock(of type: BlockType, at position: CGPoint) {
        
        let node: SKSpriteNode
        
        switch type {
        case .wall:
            node = SKSpriteNode(imageNamed: "block")
            node.position = position
            
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.categoryBitMask = CollisionMasks.wall.rawValue
            node.physicsBody?.isDynamic = false
            scene?.addChild(node)
            return
            
        case .vortex:
            node = SKSpriteNode(imageNamed: "vortex")
            node.name = "vortex"
            node.run(.repeatForever(.rotate(byAngle: .pi, duration: 1)))
            
        case .star:
            node = SKSpriteNode(imageNamed: "star")
            node.name = "star"
            
        case .finish:
            node = SKSpriteNode(imageNamed: "finish")
            node.name = "finish"
            
        case .portal:
            node = SKSpriteNode(imageNamed: "portal")
            node.name = "portal"
            
            if portals.isEmpty {
                let portal = Portal(node: node)
                portals.append(portal)
            } else {
                let portal = Portal(node: node, link: portals[0].node)
                portals[0].link = node
                portals.append(portal)
            }
            
        case .empty:
            return
        }
        
        node.position = position
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionMasks.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionMasks.player.rawValue
        node.physicsBody?.collisionBitMask = CollisionMasks.none.rawValue
        scene?.addChild(node)
    }
}


//MARK: - Clear Level
extension LevelManager {
    func clear() {
        scene?.children.forEach { child in
            guard child.name != "dontClear" else { return }
            child.removeFromParent()
        }
        
        scene?.portals = nil
    }
}


//MARK: - Player
extension LevelManager {
    func createPlayer(at position: CGPoint = CGPoint(x: 96, y: 672)) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.categoryBitMask = CollisionMasks.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionMasks.wall.rawValue
        player.physicsBody?.contactTestBitMask = CollisionMasks.vortex.rawValue
                                               | CollisionMasks.star.rawValue
                                               | CollisionMasks.finish.rawValue
        scene?.addChild(player)
        return player
    }
}


//MARK: - Score Label
extension LevelManager {
    func createScoreLabel() -> SKLabelNode {
        let node = SKLabelNode(fontNamed: "Chalkduster")
        node.text = "Score: 0"
        node.name = "dontClear"
        node.horizontalAlignmentMode = .left
        node.position = CGPoint(x: 16, y: 16)
        node.zPosition = 2
        scene?.addChild(node)
        return node
    }
}


//MARK: - Enums
extension LevelManager {
    private enum BlockType: Character {
        case wall = "x"
        case vortex = "v"
        case star = "s"
        case finish = "f"
        case empty = " "
        case portal = "p"
    }
    
    private enum CollisionMasks: UInt32 {
        case none = 0
        case player = 1
        case wall = 2
        case star = 4
        case vortex = 8
        case finish = 16
        case portal = 32
    }
}
