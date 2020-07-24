//
//  ViewController.swift
//  Project2
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    let totalQuestions = 10
    
    var countries: [String] = []
    var correctAnswerIndex = 0
    var questionCount = 0
    
    var score = 0 {
        didSet {
            checkHighScore()
        }
    }
    var highScore = 0 {
        didSet {
            saveHighScore()
        }
    }
    
    var shouldShowHighScoreAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHighScore()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderColor = UIColor.label.cgColor
        button2.layer.borderColor = UIColor.label.cgColor
        button3.layer.borderColor = UIColor.label.cgColor
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showScore))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetHighScore))
        
        askQuestion(animated: false)
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        button1.layer.borderColor = UIColor.label.cgColor
        button2.layer.borderColor = UIColor.label.cgColor
        button3.layer.borderColor = UIColor.label.cgColor
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2.0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { [weak self] _ in
            self?.evaluateAnswer(sender: sender)
        }
        
    }
    
    private func evaluateAnswer(sender: UIButton) {
        let title: String
        var message: String = ""
        let newScore: Int
        
        if sender.tag == correctAnswerIndex {
            title = "Correct"
            newScore = score + 1
        } else {
            title = "Wrong"
            message = "That's the flag of \(countries[sender.tag].uppercased()). "
            newScore = score
        }
        
        let alertController = UIAlertController(title: title, message: "\(message)Your score is \(newScore)", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            if title == "Correct" { self?.score += 1 }
            
            if self?.questionCount == self?.totalQuestions { self?.gameOver() }
            else { self?.askQuestion() }
        })
        
        present(alertController, animated: true)
    }
    
    private func askQuestion(animated: Bool = true) {
        questionCount += 1

        countries.shuffle()
        correctAnswerIndex = Int.random(in: 0...2)
        title = "\(countries[correctAnswerIndex].uppercased()), Current Score: \(score)"
        
        for (index, button) in [button1, button2, button3].enumerated() {
            
            guard let button = button else { continue }
            
            let duration = animated ? 0.2 : 0.0
            
            UIView.animate(withDuration: duration, animations: { button.alpha = 0 }) { [weak self, weak button] _ in
                guard let self = self, let button = button else { return }
                
                button.transform = .identity
                button.setImage(UIImage(named: self.countries[index]), for: .normal)
                
                UIView.animate(withDuration: duration, animations: { button.alpha = 1 })
            }
        }
    }
    
    
    private func gameOver() {
        let alertController = UIAlertController(title: "Game Finished!", message: "You finished the game with a score of \(score)/\(questionCount)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Play Again", style: .default, handler: resetGame))
        present(alertController, animated: true)
    }
    
    
    private func resetGame(action: UIAlertAction! = nil) {
        score = 0
        questionCount = 0
        shouldShowHighScoreAlert = true
        askQuestion()
    }
    
    
    @objc private func showScore() {
        let alertController = UIAlertController(title: "Score", message: "Your current score is \(score)\nThe highscore is \(highScore)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    
    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "highscore")
        shouldShowHighScoreAlert = true
    }
    
    private func checkHighScore() {
        if score > highScore {
            highScore = score
        }
    }
    
    private func saveHighScore() {
        if shouldShowHighScoreAlert {
            let ac = UIAlertController(title: "Congratulations!", message: "You just broke your high score", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Awesome", style: .default))
            present(ac, animated: true)
        }
        shouldShowHighScoreAlert = false
        
        UserDefaults.standard.set(highScore, forKey: "highscore")
    }
    
    @objc private func resetHighScore() {
        let ac = UIAlertController(title: "Confirm High Score Reset", message: "Do you really want to do this? Your highscore will be set to 0 and your current game will be reset. ", preferredStyle: .alert)
        let keepAction = UIAlertAction(title: "Keep", style: .cancel)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.shouldShowHighScoreAlert = false
            self.highScore = 0
            self.resetGame()
        }
        
        ac.addAction(keepAction)
        ac.addAction(resetAction)
        
        present(ac, animated: true)
        
    }


}

