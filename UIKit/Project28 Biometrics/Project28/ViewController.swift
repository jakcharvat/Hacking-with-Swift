//
//  ViewController.swift
//  Project28
//
//  Created by Jakub Charvat on 12/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import KeychainSwift
import LocalAuthentication

class ViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet var secret: UITextView!
    var placeholderLabel : UILabel!
    var lockButton: UIBarButtonItem!
    
    let keychain = KeychainSwift()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCentre = NotificationCenter.default
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(saveAndHide), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(authenticateTapped(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        secret.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter some text..."
        placeholderLabel.font = .preferredFont(forTextStyle: .body)
        placeholderLabel.sizeToFit()
        secret.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (secret.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !secret.text.isEmpty
        
        title = "Nothing to see here"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        lockButton = UIBarButtonItem(title: "Lock", style: .done, target: self, action: #selector(saveAndHide))
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}


//MARK: - Keyboard Adjustment
extension ViewController {
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
}


//MARK: - Unlocking Messages
extension ViewController {
    func unlockMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        if let text = keychain.get("SecretMessage") {
            secret.text = text
        }
        
        navigationItem.rightBarButtonItem = lockButton
    }
}


//MARK: - Save and Hide
extension ViewController {
    @objc func saveAndHide() {
        guard secret.isHidden == false else { return }
        keychain.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        navigationItem.rightBarButtonItem = nil
    }
}


//MARK: - Auth
extension ViewController {
    @IBAction func authenticateTapped(_ sender: UIButton? = nil) {
        
        print("auth")
        
        guard let password = keychain.get("password") else {
            promptUserToCreatePassword()
            return
        }
        
        let laContext = LAContext()
        var error: NSError?
        
        if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified. Please try again.", preferredStyle: .alert)
                        ac.addTextField { tf in
                            tf.isSecureTextEntry = true
                        }
                        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        ac.addAction(UIAlertAction(title: "Log In", style: .default) { [weak self] _ in
                            
                            guard let self = self else { return }
                            guard let enteredPassword = ac.textFields?.first?.text, enteredPassword == password else {
                                let ac = UIAlertController(title: "Incorrect password", message: nil, preferredStyle: .alert)
                                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                ac.addAction(UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                                    self?.authenticateTapped()
                                })
                                self.present(ac, animated: true)
                                return
                            }
                            
                            self.unlockMessage()
                        })
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication. Use your password instead", preferredStyle: .alert)
            ac.addTextField { tf in
                tf.isSecureTextEntry = true
            }
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Log In", style: .default) { [weak self] _ in
                
                guard let self = self else { return }
                guard let enteredPassword = ac.textFields?.first?.text, enteredPassword == password else {
                    let ac = UIAlertController(title: "Incorrect password", message: nil, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    ac.addAction(UIAlertAction(title: "Try again", style: .default) { [weak self] _ in
                        self?.authenticateTapped()
                    })
                    self.present(ac, animated: true)
                    return
                }
                
                self.unlockMessage()
            })
            present(ac, animated: true)
        }
    }
}


//MARK: - Onboarding - Create Pass
extension ViewController {
    func promptUserToCreatePassword() {
        let ac = UIAlertController(title: "Welcome!", message: "Please create a secure password to get started.", preferredStyle: .alert)
        ac.addTextField { tf in
            tf.isSecureTextEntry = true
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            guard let password = ac.textFields?.first?.text,
                password.trimmingCharacters(in: .whitespaces).count > 8 else {
                    
                    let ac = UIAlertController(title: "Invalid Password", message: "The password you entered is invalid. ", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    ac.addAction(UIAlertAction(title: "Okay", style: .default) { [weak self] _ in
                        self?.promptUserToCreatePassword()
                    })
                    
                    self.present(ac, animated: true)
                    return
            }
            
            self.keychain.set(password, forKey: "password")
            self.unlockMessage()
        })
        
        present(ac, animated: true)
    }
    
    @objc func active() {
        print("active")
        authenticateTapped()
    }
}
