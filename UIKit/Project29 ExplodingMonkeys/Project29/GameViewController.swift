//
//  GameViewController.swift
//  Project29
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var currentGame: GameScene!
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    @IBOutlet var player1ScoreLabel: UILabel!
    @IBOutlet var player2ScoreLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    
    var wind = Wind.random()
    
    var player1Score = 0 {
        didSet { player1ScoreLabel.text = "Score: \(player1Score)" }
    }
    var player2Score = 0 {
        didSet { player2ScoreLabel.text = "Score: \(player2Score)" }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                currentGame.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 120
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            updateWind()
        }
        
        angleSlider.sendActions(for: .valueChanged)
        velocitySlider.sendActions(for: .valueChanged)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(sender.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(sender.value))"
    }
    
    @IBAction func launch(_ sender: UIButton) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayer(_ number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
    }
    
    func checkHasPlayerWon(then completion: @escaping (Bool) -> ()) {
        let hasPlayer1Won = player1Score >= 3
        let hasPlayer2Won = player2Score >= 3
        
        if hasPlayer1Won || hasPlayer2Won {
            let winningPlayer = hasPlayer1Won ? "1" : "2"
            
            let ac = UIAlertController(title: "Congratulations!", message: "Player \(winningPlayer) won the game!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Play Again!", style: .default, handler: { _ in
                completion(true)
            }))
            present(ac, animated: true)
        } else {
            completion(false)
        }
    }
    
    func updateWind() {
        wind = Wind.random()
        
        let direction = wind.direction == .left ? "<---" : "--->"
        let speed = "\(wind.speed)m/s"
        let windString = wind.direction == .left ? "\(direction) \(speed)" : "\(speed) \(direction)"
        
        windLabel.text = "Wind: \n\(windString)"
        
        let gravityX = CGFloat(wind.speed) * CGFloat(wind.direction.rawValue) / 5
        
        currentGame.physicsWorld.gravity.dx = gravityX
    }
}
