//
//  ActionViewController.swift
//  Extension
//
//  Created by Jakub Charvat on 05/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet private var script: UITextView!
    
    private var pageTitle = ""
    private var pageURL = ""
    
    let scripts = [
        "Hello, World": "alert('Hello, World!')",
        "Clear Page": "Array.from(document.body.children).forEach(child => child.remove())",
        "Make Page Blue": "Array.from(document.body.children).forEach(child => child.remove()); document.body.style = 'background-color: blue'"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCentre = NotificationCenter.default
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(showActions))
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    guard let self = self else { return }
                    guard let itemDict = dict as? NSDictionary else { return }
                    guard let jsValues = itemDict[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self.pageTitle = jsValues["title"] as? String ?? ""
                    self.pageURL = jsValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self.title = self.pageTitle
                    }
                }
            }
        }
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

    @objc private func done() {
        let ac = UIAlertController(title: "Save?", message: "Do you want to save this script for later use or just run it?", preferredStyle: .alert)
        let noSaveAction = UIAlertAction(title: "Just run", style: .destructive) { [weak self] _ in
            self?.closeExtension()
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            self?.saveScript()
        }
        ac.addAction(noSaveAction)
        ac.addAction(saveAction)
        present(ac, animated: true)
    }
    
    private func saveScript() {
        let ac = UIAlertController(title: "Name", message: "What should we name this script?", preferredStyle: .alert)
        ac.addTextField()
        let saveAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let script = self.script.text, let scriptName = ac.textFields?.first?.text else { return }
            
            var dict: [String: String] = UserDefaults.standard.dictionary(forKey: "savedScripts") as? [String: String] ?? [:]
            dict[scriptName] = script
            UserDefaults.standard.set(dict, forKey: "savedScripts")
            print(dict)
            self.closeExtension()
        }
        ac.addAction(saveAction)
        present(ac, animated: true)
    }
    
    private func closeExtension() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text ?? ""]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc private func showActions() {
        let ac = UIAlertController(title: "Select Action", message: nil, preferredStyle: .actionSheet)
        let savedAction = UIAlertAction(title: "Load saved script", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.selectSavedScript()
            }
        }
        let presetAction = UIAlertAction(title: "Select preset script", style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: {
                self?.selectPreset()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        for action in [savedAction, presetAction, cancelAction] { ac.addAction(action) }
        present(ac, animated: true)
    }
    
    private func selectPreset() {
        let ac = UIAlertController(title: "Select Preset", message: nil, preferredStyle: .actionSheet)
        for (name, js) in scripts {
            let action = UIAlertAction(title: name, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.script.text = js
            }
            
            ac.addAction(action)
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func selectSavedScript() {
        let loadScriptVC = LoadScriptViewController()
        loadScriptVC.delegate = self
        let vc = UINavigationController(rootViewController: loadScriptVC)
        present(vc, animated: true)
    }

}


//MARK: - Load Script Delegate
extension ActionViewController: LoadScriptDelegate {
    func loadScript(_ loadScript: LoadScriptViewController, choseToLoad script: String) {
        self.script.text = script
    }
}
