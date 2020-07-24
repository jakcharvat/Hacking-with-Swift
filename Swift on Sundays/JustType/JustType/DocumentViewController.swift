//
//  DocumentViewController.swift
//  JustType
//
//  Created by Jakub Charvat on 29/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import Sourceful

class DocumentViewController: UIViewController, SyntaxTextViewDelegate {
    
    @IBOutlet var textView: SyntaxTextView!
    
    var document: Document?
    let lexer = SwiftLexer()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.theme = DefaultSourceCodeTheme()
        textView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissDocumentViewController))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped(_:)))
        
        document?.open { success in
            if success {
                self.textView.text = self.document?.text ?? ""
                self.title = self.document?.localizedName
            }
        }
    }
    
    @objc func dismissDocumentViewController() {
        
        if document?.text != textView.text {
            document?.text = textView.text
            document?.updateChangeCount(.done)
        }
        
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
    
    
    @objc func shareTapped(_ sender: UIBarButtonItem) {
        guard let url = document?.fileURL else { return }
        let ac = UIActivityViewController(activityItems: [ url ], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = sender
        present(ac, animated: true)
    }
    
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
}
