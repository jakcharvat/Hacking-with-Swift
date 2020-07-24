//
//  ScriptDetailViewController.swift
//  Extension
//
//  Created by Jakub Charvat on 11/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ScriptDetailViewController: UIViewController {
    
    var scriptName: String?
    var script: String?
    
    weak var delegate: ScriptDetailDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = scriptName
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Load", style: .done, target: self, action: #selector(loadButtonPressed))
        
        let label = UILabel()
        label.text = script
        label.numberOfLines = 0
        label.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(label)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scrollView.topAnchor.constraint(equalToSystemSpacingBelow: view.layoutMarginsGuide.topAnchor, multiplier: 1.0),
            scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.layoutMarginsGuide.bottomAnchor, multiplier: -1.0),
            
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            label.topAnchor.constraint(equalTo: scrollView.topAnchor),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
    }
    
    @objc private func loadButtonPressed() {
        delegate?.scriptDetailDidPressLoad(self)
    }
}

protocol ScriptDetailDelegate: class {
    func scriptDetailDidPressLoad(_ scriptDetail: ScriptDetailViewController)
}
