//
//  Player.swift
//  Project34
//
//  Created by Jakub Charvat on 16/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    var chip: ChipColor
    var color: UIColor
    var name: String
    var playerId: Int
    
    init(chip: ChipColor) {
        self.chip = chip
        self.playerId = chip.rawValue
        
        switch chip {
        case .red:
            color = .systemRed
            name = "Red"
        default:
            color = .label
            name = "Not Red"
        }
    }
    
    var opponent: Player {
        if chip == .red {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
    
    static var allPlayers = [Player(chip: .red), Player(chip: .black)]
}
