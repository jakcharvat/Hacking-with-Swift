//
//  ScoreManager.swift
//  Project14
//
//  Created by Jakub Charvat on 30/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

struct ScoreManager {
    private static let ScoreKey = "highscore"
    
    static func updateScore(_ score: Int) {
        let current = loadScore()
        guard score > current else { return }
        
        UserDefaults.standard.set(score, forKey: ScoreKey)
    }
    
    static func loadScore() -> Int {
        return UserDefaults.standard.integer(forKey: ScoreKey)
    }
    
    static func clearScore(onClear callback: @escaping () -> Void = {}) {
        guard let gameVC = UIApplication.shared.windows.first?.rootViewController as? GameViewController else { return }
        let ac = UIAlertController(title: "Clear Highscore?", message: "Are you sure you want to delete your highscore? This cannot be undone.", preferredStyle: .alert)
        let keepAction = UIAlertAction(title: "Keep", style: .cancel)
        let resetAction = UIAlertAction(title: "Clear", style: .destructive) { _ in
            UserDefaults.standard.removeObject(forKey: ScoreKey)
            callback()
        }
        
        ac.addAction(keepAction)
        ac.addAction(resetAction)
        
        gameVC.present(ac, animated: true)
    }
}
