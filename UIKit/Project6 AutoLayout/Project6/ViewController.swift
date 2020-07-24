//
//  ViewController.swift
//  Project6
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let label1 = UILabel()
    private let label2 = UILabel()
    private let label3 = UILabel()
    private let label4 = UILabel()
    private let label5 = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.backgroundColor = .red
        label1.text = "THESE"
        label1.sizeToFit()
        
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = .cyan
        label2.text = "ARE"
        label2.sizeToFit()
        
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = .yellow
        label3.text = "SOME"
        label3.sizeToFit()
        
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = .green
        label4.text = "AWESOME"
        label4.sizeToFit()
        
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.backgroundColor = .orange
        label5.text = "LABELS"
        label5.sizeToFit()
        
        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        
//        configureVFL()
        configureAnchors()
    }
}


//MARK: - VFL
extension ViewController {
    // VFL - Visual Format Language
    func configureVFL() {
        let views = ["label1": label1, "label2": label2, "label3": label3, "label4": label4, "label5": label5]
        
        for label in views.keys {
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[\(label)]|",
                options: [],
                metrics: nil,
                views: views))
        }
        
        let metrics = ["labelHeight": 88]
        let vfl = "V:|[label1(labelHeight@750)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|"
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: vfl,
            options: [],
            metrics: metrics,
            views: views))
    }
}


//MARK: - Anchors
extension ViewController {
    func configureAnchors() {
        
        var previousLabel: UILabel?
        let labels = [label1, label2, label3, label4, label5]
        let labelSpacing: CGFloat = 10
        
        for label in labels {
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            
            let labelCount = CGFloat(labels.count)
            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor,
                                          multiplier: 1 / labelCount,
                                          constant: -labelSpacing * (labelCount - 1) / labelCount).isActive = true
            
            if let previous = previousLabel {
                label.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: labelSpacing).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            }
            
            previousLabel = label
        }
        
    }
}
