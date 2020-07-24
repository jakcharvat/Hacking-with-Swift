//
//  ViewController.swift
//  Project5
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private let minLength = 3
    
    var allWords: [String] = []
    var usedWords: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        loadStartWords()
        startGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadProgress()
    }
    
    
    private func loadStartWords() {
        guard let url = Bundle.main.url(forResource: "start", withExtension: "txt") else { return }
        guard let contents = try? String(contentsOf: url) else { return }
        
        allWords = contents.components(separatedBy: "\n")
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    
    @objc private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}


//MARK: - Answer Prompt
extension ViewController {
    @objc private func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?.first?.text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
}


//MARK: - Submission
extension ViewController {
    private func submit(_ answer: String) {
        let lowercased = answer.lowercased()
        
        guard lowercased != title else {
            showErrorDialog(title: "Oi", message: "You just repeated the word we gave you. That's cheating!")
            return
        }
        guard isLongEnough(lowercased) else {
            showErrorDialog(title: "Too Short", message: "Your word must be at least three letters long. This would be too easy. ")
            return
        }
        guard isValid(lowercased) else {
            showErrorDialog(title: "Invalid Word", message: "You can't make that word out of \(title ?? "")!")
            return
        }
        guard isUnique(lowercased) else {
            showErrorDialog(title: "Word already used", message: "You used this word already. Be more original!")
            return
        }
        guard isReal(lowercased) else {
            showErrorDialog(title: "Not a real word", message: "This word isn't recognized as a valid English word. Don't make up words!")
            return
        }
        
        usedWords.insert(lowercased, at: 0)
        saveProgress()
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    /// Checks whether the provided word is longer than or equal to our minimum word length
    /// - Parameter word: The word to be checked
    /// - Returns: `true` if the word is long enough, `false` otherwise
    private func isLongEnough(_ word: String) -> Bool {
        return word.count >= minLength
    }
    
    /// Checks whether the provided word is a valid creation - ie if it only uses the characters from the original word
    /// - Parameter word: The word to be checked
    /// - Returns: `true` is the word is valid, `false` otherwise
    private func isValid(_ word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            guard let position = tempWord.firstIndex(of: letter) else { return false }
            tempWord.remove(at: position)
        }
        
        return true
    }
    
    /// Checks whether the provided word is unique - ie ensures it hasn't been used yet
    /// - Parameter word: The word to be checked
    /// - Returns: `true` if the word is unique, `false` otherwise
    private func isUnique(_ word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    /// Checks whether the provided word is real - ie if it's actually a valid word in English
    /// - Parameter word: The word to be checked
    /// - Returns: `true` if the word is real, `false` otherwise
    private func isReal(_ word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(word.startIndex..., in: word)
        let misspeltRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspeltRange.location == NSNotFound
    }
    
    
    private func showErrorDialog(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
}


//MARK: - TableView
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}


//MARK: - User Defaults
extension ViewController {
    private func saveProgress() {
        guard let prompt = title else { return }
        guard let usedWords = try? JSONEncoder().encode(usedWords) else { return }
        
        UserDefaults.standard.set(prompt, forKey: "prompt")
        UserDefaults.standard.set(usedWords, forKey: "usedWords")
    }
    
    private func loadProgress() {
        if let prompt = UserDefaults.standard.string(forKey: "prompt") {
            title = prompt
        }
        
        if let data = UserDefaults.standard.data(forKey: "usedWords") {
            if let words = try? JSONDecoder().decode([String].self, from: data) {
                usedWords = words
                let indexPaths = (0 ..< usedWords.count).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
}

