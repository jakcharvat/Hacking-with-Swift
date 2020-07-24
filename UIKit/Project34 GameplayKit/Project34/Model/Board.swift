//
//  Board.swift
//  Project34
//
//  Created by Jakub Charvat on 16/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import GameplayKit

class Board: NSObject {
    static var width = 7
    static var height = 6
    
    var currentPlayer: Player
    
    private var slots = [ChipColor]()
    
    override init() {
        currentPlayer = Player.allPlayers[0]
        
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        
        super.init()
    }
    
    func chip(inColumn column: Int, row: Int) -> ChipColor {
        return slots[row + column * Board.height]
    }
    
    func set(chip: ChipColor, in column: Int, row: Int) {
        slots[row + column * Board.height] = chip
    }
    
    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: column, row: row) == .none {
                return row
            }
        }
        
        return nil
    }
    
    func canMove(in column: Int) -> Bool {
        return nextEmptySlot(in: column) != nil
    }
    
    func add(chip: ChipColor, in column: Int) {
        if let row = nextEmptySlot(in: column) {
            set(chip: chip, in: column, row: row)
        }
    }
    
    func isFull() -> Bool {
        for column in 0 ..< Board.width {
            if canMove(in: column) {
                return false
            }
        }
        
        return true
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! Player).chip
        
        for col in 0 ..< Board.width {
            for row in 0 ..< Board.width {
                
                if squaresMatch(initialChip: chip, col: col, row: row, moveX: 1, moveY: 0) { return true }
                if squaresMatch(initialChip: chip, col: col, row: row, moveX: 0, moveY: 1) { return true }
                if squaresMatch(initialChip: chip, col: col, row: row, moveX: 1, moveY: 1) { return true }
                if squaresMatch(initialChip: chip, col: col, row: row, moveX: 1, moveY: -1) { return true }
                
            }
        }
        
        return false
    }
    
    func squaresMatch(initialChip: ChipColor, col: Int, row: Int, moveX: Int, moveY: Int) -> Bool {
        // Bail out if we cannot win from this position (too close to the edge of the board)
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        // Now check every square to see if it matches our initial color
        if chip(inColumn: col, row: row) != initialChip { return false }
        if chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }
        
        return true
    }
}


//MARK: - GKGameModel
extension Board: GKGameModel {
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots
            currentPlayer = board.currentPlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
            
            var moves = [Move]()
            
            for col in 0 ..< Board.width {
                if canMove(in: col) {
                    moves.append(Move(column: col))
                }
            }
            
            return moves
        }
        
        return nil
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, in: move.column)
            currentPlayer = currentPlayer.opponent
        }
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) { return 1000 }
            if isWin(for: playerObject.opponent) { return -1000 }
        }
        
        return 0
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
}


enum ChipColor: Int {
    case none = 0
    case red
    case black
}
