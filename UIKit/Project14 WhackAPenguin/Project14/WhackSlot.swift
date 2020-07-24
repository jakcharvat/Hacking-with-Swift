//
//  WhackSlot.swift
//  Project14
//
//  Created by Jakub Charvat on 30/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

//MARK: - Properties
class WhackSlot: SKNode {
    static let CharacterNodeName = "character"
    static let CharacterNameGood = "charFriend"
    static let CharacterNameEvil = "charEnemy"
    
    private(set) var isPenguinVisible = false
    private(set) var isHit = false
    
    private(set) var charNode: SKSpriteNode!
    private var charMaskNode: SKCropNode!
}


//MARK: - Config
extension WhackSlot {
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        createCharacter()
    }
}


//MARK: - Character Creation
extension WhackSlot {
    private func createCharacter() {
        charMaskNode = SKCropNode()
        charMaskNode.position = CGPoint(x: 0, y: 15)
        charMaskNode.zPosition = 1
        charMaskNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = WhackSlot.CharacterNodeName
        charMaskNode.addChild(charNode)
        
        addChild(charMaskNode)
    }
}


//MARK: - Show Penguin
extension WhackSlot {
    func showPenguin(for popupTime: Double) {
        if isPenguinVisible { return }
        
        charNode.setScale(1)
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        runMudParticles()
        isPenguinVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = WhackSlot.CharacterNameGood
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = WhackSlot.CharacterNameEvil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (popupTime * 3.5)) { [weak self] in
            self?.hidePenguin()
        }
    }
}


//MARK: - Hide Penguin
extension WhackSlot {
    func hidePenguin() {
        guard isPenguinVisible else { return }
        
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.moveBy(x: 0, y: -80, duration: 0.05),
            SKAction.run { [weak self] in self?.isPenguinVisible = false }
        ])
        charNode.run(sequence)
        runMudParticles()
    }
}


//MARK: - Hit
extension WhackSlot {
    func hit() {
        isHit = true
        
        let particles = SKEmitterNode(fileNamed: "HitParticles")!
        particles.position = charNode.position
        particles.zPosition = 1
        addChild(particles)
        
        let removeAction = SKAction.sequence([.wait(forDuration: 1), .removeFromParent()])
        particles.run(removeAction)
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let invisible = SKAction.run { [weak self] in self?.isPenguinVisible = false }
        
        charNode.run(SKAction.sequence([delay, hide, invisible]))
    }
}


//MARK: - Mud Particles
extension WhackSlot {
    private func runMudParticles() {
        let node = SKEmitterNode(fileNamed: "MudParticles")!
        node.position = CGPoint(x: 0, y: -40)
        node.zPosition = 2
        charMaskNode.addChild(node)
        
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.removeFromParent()
        ])
        node.run(sequence)
    }
}
