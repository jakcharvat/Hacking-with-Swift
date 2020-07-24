//
//  GameScene.swift
//  Project14
//
//  Created by Jakub Charvat on 30/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import GameplayKit


//MARK: - Properties
class GameScene: SKScene {
    
    private var scoreLabel: SKLabelNode!
    private var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var highscoreLabel: SKLabelNode!
    private var highscore = 0 {
        didSet {
            highscoreLabel.text = "Highscore: \(highscore)"
        }
    }
    
    private var slots: [WhackSlot] = []
    
    private var popupTime = 0.85
    private var rounds = 0
}


//MARK: - Lifecycle
extension GameScene {
    override func didMove(to view: SKView) {
        createUI()
        createSlots()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
        
        highscore = ScoreManager.loadScore()
    }
}


//MARK: - Slot Creation
extension GameScene {
    private func createSlots() {
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0 ..< 5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0 ..< 4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
    }
    
    private func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
}


//MARK: - UI Creation
extension GameScene {
    private func createUI() {
        createBackground()
        createScoreLabel()
        createHighscoreLabel()
    }
    
    private func createBackground() {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.setScale(max(frame.width / background.size.width, frame.height / background.size.height))
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    private func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: 8, y: 8)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
    }
    
    private func createHighscoreLabel() {
        highscoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highscoreLabel.text = "Highscore: 0"
        highscoreLabel.fontColor = .black
        highscoreLabel.position = CGPoint(x: scoreLabel.position.x + scoreLabel.frame.width + 44, y: scoreLabel.position.y)
        highscoreLabel.horizontalAlignmentMode = .left
        highscoreLabel.fontSize = 20
        highscoreLabel.name = "highscore"
        addChild(highscoreLabel)
    }
}


//MARK: - Enemy Creation
extension GameScene {
    private func createEnemy() {
        
        rounds += 1
        if checkIsGameOver() { return }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].showPenguin(for: popupTime)
        
        let rand = Int.random(in: 0...12)
        if rand > 4 { slots[1].showPenguin(for: popupTime) }
        if rand > 8 { slots[2].showPenguin(for: popupTime) }
        if rand > 10 { slots[3].showPenguin(for: popupTime) }
        if rand > 11 { slots[4].showPenguin(for: popupTime) }
        
        let minDelay = popupTime / 2
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
}


//MARK: - Game Over
extension GameScene {
    private func checkIsGameOver() -> Bool {
        
        if rounds >= 30 {
            
            for slot in slots { slot.hidePenguin() }
            
            let gameover = SKSpriteNode(imageNamed: "gameOver")
            gameover.position = CGPoint(x: frame.midX, y: frame.midY)
            gameover.zPosition = 2
            addChild(gameover)
            
            ScoreManager.updateScore(score)
            highscore = ScoreManager.loadScore()
            
            return true
        }
        
        return false
        
    }
}


//MARK: - Touches
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            whackPenguins(at: location)
        }
        
    }
    
    private func whackPenguins (at location: CGPoint) {
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node.name == "highscore" {
                ScoreManager.clearScore { [weak self] in self?.highscore = ScoreManager.loadScore() }
                continue
            }
            
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            guard whackSlot.isPenguinVisible else { continue }
            if whackSlot.isHit { continue }
            
            whackSlot.hit()
            
            switch node.name {
            case WhackSlot.CharacterNameGood:
                score -= 5
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            case WhackSlot.CharacterNameEvil:
                whackSlot.charNode.setScale(0.85)
                score += 1
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            default:
                continue
            }
            
        }
    }
}
