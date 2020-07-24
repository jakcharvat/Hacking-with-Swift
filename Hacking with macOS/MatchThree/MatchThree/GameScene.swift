//
//  GameScene.swift
//  MatchThree
//
//  Created by Jakub Charvat on 17/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var nextBall = GKShuffledDistribution(lowestValue: 0, highestValue: 3)
    var cols = [[Ball]]()
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            
            if let formattedScore = formatter.string(from: score as NSNumber) {
                scoreLabel.text = "Score: \(formattedScore)"
            }
        }
    }
    
    var timer: SKShapeNode!
    let timeLimit: Double = 100
    var gameStartTime: TimeInterval = 0
    
    let ballSize: CGFloat = 50.0
    let ballsPerCol = 10
    let ballsPerRow = 14
    
    var currentMatches = Set<Ball>()
    
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        populateGrid()
        createUI()
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        
        if gameStartTime == 0 {
            gameStartTime = currentTime
        }
        
        let elapsed = currentTime - gameStartTime
        let remaining = timeLimit - elapsed
        timer.xScale = max(0, CGFloat(remaining / timeLimit))
        
        if remaining < 0 {
            gameOver()
        }
    }
}


//MARK: - Ball Position
extension GameScene {
    func position(of ball: Ball) -> CGPoint {
        let x = 72 + ballSize * CGFloat(ball.col)
        let y = 50 + ballSize * CGFloat(ball.row)
        
        return CGPoint(x: x, y: y)
    }
}


//MARK: - Ball Creation
extension GameScene {
    func createBall(at row: Int, _ col: Int, startOffscreen: Bool = false) -> Ball {
        let ballImages = [ "ballBlue", "ballGreen", "ballPurple", "ballRed" ]
        let ballImage = ballImages[nextBall.nextInt()]
        
        let ball = Ball(imageNamed: ballImage)
        ball.row = row
        ball.col = col
        
        if startOffscreen {
            let finalPosition = position(of: ball)
            ball.position = finalPosition
            ball.position.y += 600
            
            let action = SKAction.move(to: finalPosition, duration: 0.4)
            ball.run(action) { [unowned self] in
                self.isUserInteractionEnabled = true
            }
        } else {
            ball.position = position(of: ball)
        }
        
        ball.name = ballImage
        addChild(ball)
        
        return ball
    }
}


//MARK: - Populating Grid
extension GameScene {
    func populateGrid() {
        for x in 0 ..< ballsPerRow {
            var col = [Ball]()
            
            for y in 0 ..< ballsPerCol {
                let ball = createBall(at: y, x)
                col.append(ball)
            }
            
            cols.append(col)
        }
    }
}


//MARK: - Ball Identification
extension GameScene {
    func ball(at point: CGPoint) -> Ball? {
        let balls = nodes(at: point).compactMap { $0 as? Ball }
        return balls.first
    }
}


//MARK: - Matching balls
extension GameScene {
    func match(from originalBall: Ball) {
        var checkBalls = [Ball?]()
        
        currentMatches.insert(originalBall)
        
        let pos = originalBall.position
        
        checkBalls.append(ball(at: CGPoint(x: pos.x, y: pos.y - ballSize)))
        checkBalls.append(ball(at: CGPoint(x: pos.x, y: pos.y + ballSize)))
        checkBalls.append(ball(at: CGPoint(x: pos.x - ballSize, y: pos.y)))
        checkBalls.append(ball(at: CGPoint(x: pos.x + ballSize, y: pos.y)))
        
        for case let check? in checkBalls {
            if currentMatches.contains(check) { continue }
            
            if check.name == originalBall.name {
                match(from: check)
            }
        }
    }
}


//MARK: - Destroying balls
extension GameScene {
    func destroy(_ ball: Ball) {
        if let particles = SKEmitterNode(fileNamed: "Fire") {
            particles.position = ball.position
            addChild(particles)
            
            let wait = SKAction.wait(forDuration: TimeInterval(particles.particleLifetime))
            particles.run(.sequence([ wait, .removeFromParent() ]))
        }
        
        cols[ball.col].remove(at: ball.row)
        ball.removeFromParent()
    }
}


//MARK: - Mousedown
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        guard !isGameOver else { newGame(); return }
        
        let location = event.location(in: self)
        guard let clickedBall = ball(at: location) else { return }
        
        isUserInteractionEnabled = false
        
        currentMatches.removeAll()
        match(from: clickedBall)
        
        let sortedMatches = currentMatches.sorted { $0.row > $1.row }
        for match in sortedMatches { destroy(match) }
        
        for (y, col) in cols.enumerated() {
            for (x, ball) in col.enumerated() {
                ball.row = x
                let action = SKAction.move(to: position(of: ball), duration: 0.1)
                ball.run(action)
            }
            
            while cols[y].count < ballsPerCol {
                let ball = createBall(at: cols[y].count, y, startOffscreen: true)
                cols[y].append(ball)
            }
        }
        
        let newScore = currentMatches.count
        
        if newScore == 1 {
            gameOver()
        } else if newScore > 2 {
            let scoreToAdd = pow(2, Double(min(newScore, 16)))
            score += Int(scoreToAdd)
        }
    }
}


//MARK: - UI
extension GameScene {
    func createUI() {
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 55, y: frame.maxY - 55)
        addChild(scoreLabel)
        
        timer = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 200, height: 40))
        timer.fillColor = .green
        timer.strokeColor = .clear
        timer.position = CGPoint(x: 545, y: 539)
        addChild(timer)
    }
}


//MARK: - Game Over
extension GameScene {
    func gameOver() {
        guard !isGameOver else { return }
        
        isGameOver = true
        let goLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        goLabel.text = "Game Over"
        goLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        goLabel.verticalAlignmentMode = .center
        goLabel.horizontalAlignmentMode = .center
        goLabel.fontSize = 100
        goLabel.setScale(0.8)
        goLabel.alpha = 0
        goLabel.zPosition = 1
        addChild(goLabel)
        
        goLabel.run(.group([
            .fadeIn(withDuration: 0.25),
            .scale(to: 1, duration: 0.25)
        ]))
    }
}


//MARK: - New Game
extension GameScene {
    func newGame() {
        if let newGame = SKScene(fileNamed: "GameScene") {
            view?.presentScene(newGame, transition: .fade(withDuration: 1))
        }
    }
}
