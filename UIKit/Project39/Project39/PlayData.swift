//
//  PlayData.swift
//  Project39
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

class PlayData {
    private var allWords = [String]()
    private(set) var filteredWords = [String]()
    
    private(set) var wordCounts: NSCountedSet!
    
    init() {
        if let path = Bundle.main.path(forResource: "plays", ofType: "txt") {
            guard let plays = try? String(contentsOfFile: path) else { return }
            allWords = plays.components(separatedBy: CharacterSet.alphanumerics.inverted)
            
            allWords = allWords.filter { $0 != "" }
            
            wordCounts = NSCountedSet(array: allWords)
            let sorted = wordCounts.allObjects.sorted { wordCounts.count(for: $0) > wordCounts.count(for: $1) }
            allWords = sorted as! [String]
            
//            applyUserFilter("swift")
            applyFilter(filter: .allItems)
        }
    }
    
    
    func applyUserFilter(_ input: String) {
        
        if let count = Int(input) {
            // We got a number representing a word count. Show all words that have a frequence greater than or equal to the input.
            applyFilter { wordCounts.count(for: $0) >= count }
        } else {
            // We got a string. Show all words that contain that string.
            
            guard !input.isEmpty else {
                applyFilter(filter: .allItems)
                return
            }
            
            applyFilter { $0.range(of: input, options: .caseInsensitive) != nil }
        }
        
    }
    
    
    func applyFilter(_ filter: (String) -> Bool) {
        filteredWords = allWords.filter(filter)
    }
    
    func applyFilter(filter: SearchFilter) {
        switch filter {
        case .allItems:
            filteredWords = allWords
        }
    }
}

enum SearchFilter {
    case allItems
}
