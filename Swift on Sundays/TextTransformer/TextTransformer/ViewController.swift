//
//  ViewController.swift
//  TextTransformer
//
//  Created by Jakub Charvat on 29/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet var input: NSTextField!
    @IBOutlet var type: NSSegmentedControl!
    @IBOutlet var output: NSTextField!
    
    let zalgoCharacters = ZalgoCharacters()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let text = UserDefaults.standard.string(forKey: "text") ?? ""
        let index = UserDefaults.standard.integer(forKey: "index")
        
        input.stringValue = text
        type.selectedSegment = index
        typeChanged(self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func typeChanged(_ sender: Any) {
        switch type.selectedSegment {
        case 0:
            output.stringValue = rot13(input.stringValue)
        case 1:
            output.stringValue = similar(input.stringValue)
        case 2:
            output.stringValue = strike(input.stringValue)
        default:
            output.stringValue = zalgo(input.stringValue)
        }
    }
    
    @IBAction func copyPressed(_ sender: NSButton) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(output.stringValue, forType: .string)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        typeChanged(self)
    }
    
    
    private func rot13(_ input: String) -> String {
        return ROT13.string(input)
    }
    
    private func similar(_ input: String) -> String {
        let letterCombos = [
            "a": "а",
            "e": "е",
            "i": "і",
            "o": "о",
        ]
        
        var output = input
        
        for (original, changed) in letterCombos {
            output = output.replacingOccurrences(of: original, with: changed)
            output = output.replacingOccurrences(of: original.uppercased(), with: changed.uppercased())
        }
        
        return output
    }
    
    private func strike(_ input: String) -> String {
        var output = ""
        
        for letter in input {
            output.append(letter)
            output.append("\u{0335}")
        }
        
        return output
    }
    
    private func zalgo(_ input: String) -> String {
        var output = ""
        
        for letter in input {
            output.append(letter)
            
            for _ in 1 ... .random(in: 1...8) {
                output.append(zalgoCharacters.above.randomElement())
                output.append(zalgoCharacters.below.randomElement())
            }
            
            for _ in 1 ... .random(in: 1...3) {
                output.append(zalgoCharacters.inline.randomElement())
            }
        }
        
        return output
    }
    
    
    override func viewWillDisappear() {
        let text = input.stringValue
        let index = type.selectedSegment
        
        UserDefaults.standard.set(text, forKey: "text")
        UserDefaults.standard.set(index, forKey: "index")
    }
}


extension String {
    mutating func append(_ str: String?) {
        guard let str = str else { return }
        append(str)
    }
}
