//
//  ContentView.swift
//  WordScramble
//
//  Created by Jakub Charvat on 17/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self) { word in
                    Image(systemName: "\(word.count).circle")
                    Text(word)
                }
                
                HStack {
                    Text("Score: \(score)")
                        .font(.headline)
                    Spacer()
                }.padding()
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingErrorAlert) { () -> Alert in
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Okay")))
            }
            .navigationBarItems(trailing: Button(action: startGame) {
                Image(systemName: "arrow.counterclockwise")
            })
        }
    }
    
    
    func startGame() {
        if let url = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: url) {
                let allWords = startWords.components(separatedBy: .newlines)
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords = [String]()
                score = 0
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard answer != rootWord else {
            showError(title: "Cheater!", message: "You can't just use the start word. That's cheating")
            return
        }
        
        guard isLongEnough(word: answer) else {
            showError(title: "Too short", message: "The word you enter must be at least three characters long")
            return
        }
        
        guard isOriginal(word: answer) else {
            showError(title: "Word already used", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            showError(title: "Impossible word", message: "You can't make that word from the start word you were given")
            return
        }
        
        guard isReal(word: answer) else {
            showError(title: "Not a word", message: "This isn't a valid English word")
            return
        }
        
        score += answer.count
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    
    func isLongEnough(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspeltRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspeltRange.location == NSNotFound
    }
    
    func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingErrorAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
