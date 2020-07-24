//
//  AddCommentsVC.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class AddCommentsVC: UIViewController {
    
    var genre: Genre!
    var uuidString: String!
    
    var comments: UITextView!
    var placeholder: UILabel!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = .preferredFont(forTextStyle: .body)
        view.addSubview(comments)
        
        NSLayoutConstraint.activate([
            comments.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            comments.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            comments.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            comments.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePlaceholder(for: comments)
        configureNavbar()
    }
    
    func configurePlaceholder(for textView: UITextView) {
        placeholder = UILabel()
        placeholder.text = "Enter some text..."
        placeholder.font = textView.font
        placeholder.sizeToFit()
        textView.addSubview(placeholder)
        placeholder.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholder.textColor = .placeholderText
        placeholder.isHidden = !textView.text.isEmpty
    }
    
    func configureNavbar() {
        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitTapped(_:)))
    }
    
    @objc func submitTapped(_ sender: UIBarButtonItem) {
        let vc = SubmitVC()
        vc.uuidString = uuidString
        vc.genre = genre
        vc.comments = comments.text
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension AddCommentsVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
    }
}
