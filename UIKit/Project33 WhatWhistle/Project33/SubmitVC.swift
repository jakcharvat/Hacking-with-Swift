//
//  SubmitVC.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class SubmitVC: UIViewController {
    
    var uuidString: String!
    var genre: Genre!
    var comments: String!
    
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        createStack()
        createStatus()
        createSpinner()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        doSubmission()
    }
    
    func createStack() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func createStatus() {
        status = UILabel()
        status.text = "Submitting..."
        status.translatesAutoresizingMaskIntoConstraints = false
        status.textColor = .label
        status.numberOfLines = 0
        status.font = .preferredFont(forTextStyle: .title1)
        status.textAlignment = .center
        
        stackView.addArrangedSubview(status)
    }
    
    func createSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(spinner)
    }
    
    func configureNavbar() {
        title = "All set!"
        navigationItem.hidesBackButton = true
    }
}


//MARK: - Saving
extension SubmitVC {
    func doSubmission() {
        let whistle = Whistle(genre: genre, comments: comments, id: uuidString)
        if let rootVC = (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.viewControllers.first as? RootVC {
            let success = rootVC.whistleManager.addWhistle(whistle)
            
            if success {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped(_:)))
                spinner.stopAnimating()
                status.text = "Success!"
                return
            }
        }
        
        let ac = UIAlertController(title: "Save Failed", message: "There was an error saving the whistle. Would you like to try again? Pressing Cancel will destroy the recording. ", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [unowned self] _ in
            let recordingURL = RecordWhistleVC.getDocumentsDirectory().appendingPathComponent("\(self.uuidString ?? "").m4a")
            try? FileManager.default.removeItem(at: recordingURL)
            _ = self.navigationController?.popToRootViewController(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [unowned self] _ in
            self.doSubmission()
        }))
        present(ac, animated: true)
    }
    
    @objc func doneTapped(_ sender: UIBarButtonItem) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
}
