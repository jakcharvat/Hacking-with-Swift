//
//  ViewController.swift
//  Cows and Bulls
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet private var tableView: NSTableView!
    @IBOutlet private var guessTextField: NSTextField!
    
    private var answer = ""
    private var guesses = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        startNewGame()
    }

    @IBAction private func goTapped(_ sender: NSButton) {
        let guessString = guessTextField.stringValue
        guard guessString.count == 4, Set(guessString).count == 4 else { return }
        
        let badCharacters = CharacterSet(charactersIn: "1234567890").inverted
        guard guessString.rangeOfCharacter(from: badCharacters) == nil else { return }
        
        guesses.insert(guessString, at: 0)
        tableView.insertRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
        
        let resultString = result(for: guessString)
        
        if resultString.contains("4b") {
            let alert = NSAlert()
            alert.messageText = "You win"
            alert.informativeText = "Congratulations, you won in \(guesses.count) moves! Click OK to play again"
            alert.runModal()
            
            startNewGame()
        }
    }
}


//MARK: - DataSource
extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        guesses.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        
        if tableColumn?.title == "Guess" {
            vw.textField?.stringValue = guesses[row]
        } else {
            vw.textField?.stringValue = result(for: guesses[row])
        }
        
        return vw
    }
}


//MARK: - Delegate
extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}


//MARK: - Game Management
extension ViewController {
    private func startNewGame() {
        guessTextField.stringValue = ""
        guesses.removeAll()
        answer = ""
        
        let numbers = Array(0...9).map(String.init).shuffled()
        answer = numbers[..<4].joined()
        print(answer)
        
        tableView.reloadData()
    }
    
    private func result(for guess: String) -> String {
        var bulls = 0
        var cows = 0
        
        let guessLetters = Array(guess)
        let answerLetters = Array(answer)
        
        for (index, char) in guessLetters.enumerated() {
            if char == answerLetters[index] { bulls += 1 }
            else if answerLetters.contains(char) { cows += 1 }
        }
        
        return "\(bulls)b \(cows)c"
    }
}
