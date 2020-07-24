//
//  ViewController.swift
//  Project8
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let scoreLabel = UILabel()
    private let cluesLabel = UILabel()
    private let answersLabel = UILabel()
    private let currentAnswer = UITextField()
    
    private let submitButton = UIButton(type: .system)
    private let clearButton = UIButton(type: .system)
    
    
    private var cluesAnswersRow: UIStackView!
    private var submitClearRow: UIStackView!
    
    private let buttonsView = UIView()
    private var letterButtons: [UIButton] = []
    
    private let buttonWidth: CGFloat = 150
    private let buttonHeight: CGFloat = 80
    private let buttonCols = 5
    private let buttonRows = 4
    
    private var activatedButtons: [UIButton] = []
    private var solutions: [String] = []
    
    private var levelIndex = 0
    private var levels: [String] = []
    
    private var score = 0 {
        didSet {
            if score < 0 { score = 0 }
            
            scoreLabel.text = "Score: \(score)"
        }
    }
}
 

//MARK: - Load
extension ViewController {
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = .systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = .systemFont(ofSize: 24)
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = .systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        
        cluesAnswersRow = UIStackView(arrangedSubviews: [cluesLabel, answersLabel])
        cluesAnswersRow.translatesAutoresizingMaskIntoConstraints = false
        cluesAnswersRow.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped(_:)), for: .touchUpInside)
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("CLEAR", for: .normal)
        clearButton.addTarget(self, action: #selector(clearTapped(_:)), for: .touchUpInside)
        
        submitClearRow = UIStackView(arrangedSubviews: [submitButton, clearButton])
        submitClearRow.translatesAutoresizingMaskIntoConstraints = false
        submitClearRow.spacing = 20
        
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scoreLabel)
        view.addSubview(cluesAnswersRow)
        view.addSubview(currentAnswer)
        view.addSubview(submitClearRow)
        view.addSubview(buttonsView)
        
        configureConstraints()
        configureLetterButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getAvailableLevels()
            self.loadLevel()
        }
    }
}


//MARK: - Constraints
extension ViewController {
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            cluesAnswersRow.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesAnswersRow.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesAnswersRow.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            cluesLabel.widthAnchor.constraint(equalTo: cluesAnswersRow.widthAnchor, multiplier: 0.6),
            answersLabel.widthAnchor.constraint(equalTo: cluesAnswersRow.widthAnchor, multiplier: 0.4),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            {
                let constraint = cluesAnswersRow.heightAnchor.constraint(equalToConstant: 10000)
                constraint.priority = .defaultLow
                return constraint
            }(),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: cluesAnswersRow.bottomAnchor, constant: 20),
            
            submitClearRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitClearRow.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submitClearRow.heightAnchor.constraint(equalToConstant: 44),
            submitButton.widthAnchor.constraint(equalTo: clearButton.widthAnchor),
            
            buttonsView.widthAnchor.constraint(equalToConstant: buttonWidth * CGFloat(buttonCols)),
            buttonsView.heightAnchor.constraint(equalToConstant: buttonHeight * CGFloat(buttonRows)),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            
        ])
    }
}


//MARK: - Letter Buttons
extension ViewController {
    func configureLetterButtons() {
        
        var rows: [UIStackView] = []
        for _ in 0 ..< buttonRows { // Rows
            
            var buttons: [UIButton] = []
            
            for _ in 0 ..< buttonCols { // Columns
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = .systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
                
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                letterButton.layer.cornerRadius = 10
                
                letterButtons.append(letterButton)
                buttons.append(letterButton)
            }
            
            let row = UIStackView(arrangedSubviews: buttons)
            row.spacing = 2
            row.translatesAutoresizingMaskIntoConstraints = false
            rows.append(row)
            
        }
        
        let stack = UIStackView(arrangedSubviews: rows)
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        buttonsView.addSubview(stack)
        
        stack.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor).isActive = true
        stack.topAnchor.constraint(equalTo: buttonsView.topAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor).isActive = true
        
        var previousRow: UIView?
        for row in stack.arrangedSubviews {
            
            guard let row = row as? UIStackView else { continue }
            
            if let previousRow = previousRow {
                row.heightAnchor.constraint(equalTo: previousRow.heightAnchor).isActive = true
            }
            previousRow = row
            
            var previousButton: UIView?
            for button in row.arrangedSubviews {
                
                if let previousButton = previousButton {
                    button.widthAnchor.constraint(equalTo: previousButton.widthAnchor).isActive = true
                }
                previousButton = button
                
            }
            
        }
        
    }
}


//MARK: - Button Taps
extension ViewController {
    @objc private func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }
        
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        
        animate { sender.alpha = 0 }
    }
    
    @objc private func submitTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        
        if let solutionPosition = solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            solutions.remove(at: solutionPosition)
            
            if solutions.isEmpty {
                showLevelFinishedAlert()
            }
            
            return
        }
        
        let ac = UIAlertController(title: "Incorrect Guess", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
            self?.score -= 1
            self?.clearTapped()
        }
        
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    @objc private func clearTapped(_ sender: UIButton? = nil) {
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            animate { btn.alpha = 1 }
        }
        
        activatedButtons.removeAll()
        
    }
    
    private func showLevelFinishedAlert() {
        let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
        present(ac, animated: true)
    }
    
    private func levelUp(action: UIAlertAction) {
        levelIndex += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            animate { btn.alpha = 1 }
        }
    }
}


//MARK: - Level Loading
extension ViewController {
    private func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits: [String] = []
        
        if levelIndex >= levels.count { levelIndex = 0 }
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let url = Bundle.main.url(forResource: self.levels[self.levelIndex], withExtension: "txt") else { return }
            guard let contents = try? String(contentsOf: url) else { return }
            
            var lines = contents.components(separatedBy: "\n")
            lines.shuffle()
            
            for (index, line) in lines.enumerated() {
                let parts = line.components(separatedBy: ": ")
                let answer = parts[0]
                let clue = parts[1]
                
                clueString += "\(index + 1). \(clue)\n"
                
                let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                solutionString += "\(solutionWord.count) letters\n"
                self.solutions.append(solutionWord)
                
                let bits = answer.components(separatedBy: "|")
                letterBits += bits
            }
            
            DispatchQueue.main.async {
                self.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                self.answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            letterBits.shuffle()
            
            guard letterBits.count == self.letterButtons.count else { return }
            
            for i in 0 ..< self.letterButtons.count {
                DispatchQueue.main.async { self.letterButtons[i].setTitle(letterBits[i], for: .normal) }
            }
        }
    }
    
    private func getAvailableLevels() {
        let fm = FileManager()
        guard let path = Bundle.main.resourcePath else { return }
        guard let files = try? fm.contentsOfDirectory(atPath: path) else { return }
        
        levels = files
            .filter { $0.hasPrefix("level") && $0.hasSuffix(".txt") }
            .sorted { Int(extractedFrom: $0)! < Int(extractedFrom: $1)! }
            .map { $0.components(separatedBy: ".").first! }
    }
}


extension Int {
    init?(extractedFrom string: String) {
        let num = string.filter { "1234567890".contains($0) }
        self.init(num)
    }
}


//MARK: - Animation
extension ViewController {
    private func animate(animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: animations)
    }
}
