//
//  AuthVC.swift
//  Project33
//
//  Created by Jakub Charvat on 20/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class AuthVC: UIViewController {
    
    private var loginView: AuthView!
    private var signupView: AuthView!
    private var currentView: AuthView!
    private var loadingOverlay: LoadingOverlay!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLoad() {
        configureNavbar()
        createAuthViews()
        createLoadingOverlay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func configureNavbar() {
        title = "Log In"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func createAuthViews() {
        loginView = AuthView()
        signupView = AuthView()
        signupView.alpha = 0
        
        currentView = loginView

        view.addSubview(loginView)
        view.addSubview(signupView)

        loginView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        signupView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.leading.equalTo(view).inset(40)
            make.trailing.equalTo(view).inset(-40)
        }
        
        configureLoginView()
        configureSignupView()
    }
    
    func configureLoginView() {
        loginView.mainButton.addTarget(self, action: #selector(loginTapped(_:)), for: .touchUpInside)
        loginView.mainButton.setTitle("Log in", for: .normal)
        loginView.secondaryButton.addTarget(self, action: #selector(moveToSignup), for: .touchUpInside)
        loginView.secondaryButton.setTitle("Sign up", for: .normal)
        
        loginView.emailTF.textContentType = .emailAddress
        loginView.passwordTF.textContentType = .password
    }
    
    func configureSignupView() {
        signupView.mainButton.addTarget(self, action: #selector(signupTapped(_:)), for: .touchUpInside)
        signupView.mainButton.setTitle("Sign up", for: .normal)
        signupView.secondaryButton.addTarget(self, action: #selector(moveToLogin), for: .touchUpInside)
        signupView.secondaryButton.setTitle("Log in", for: .normal)
        
        signupView.emailTF.textContentType = .emailAddress
        signupView.passwordTF.textContentType = .newPassword
    }
    
    func createLoadingOverlay() {
        loadingOverlay = LoadingOverlay()
        loadingOverlay.alpha = 0
        view.addSubview(loadingOverlay)
        loadingOverlay.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
}


//MARK: - Switching Views
extension AuthVC {
    @objc func moveToLogin() {
        guard currentView == signupView else { return }
        
        transition(from: signupView, to: loginView, backwards: true)
    }
    
    @objc func moveToSignup() {
        guard currentView == loginView else { return }
        
        transition(from: loginView, to: signupView)
    }
    
    private func transition(from initialView: AuthView, to finalView: AuthView, backwards: Bool = false) {
        let dx = backwards ? 40 : -40
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            initialView.snp.remakeConstraints { make in
                make.top.bottom.equalTo(self.view)
                make.leading.equalTo(self.view).inset(dx)
                make.trailing.equalTo(self.view).inset(-dx)
            }
            
            self.view.layoutIfNeeded()
            initialView.alpha = 0
        }) { [unowned self] _ in
            self.currentView = finalView

            finalView.emailTF.text = initialView.emailTF.text
            finalView.passwordTF.text = initialView.passwordTF.text
            
            if initialView.emailTF.isFirstResponder {
                finalView.emailTF.becomeFirstResponder()
            }
            
            if initialView.passwordTF.isFirstResponder {
                finalView.passwordTF.becomeFirstResponder()
            }
            
            finalView.validateAll()
            
            self.title = finalView == self.signupView ? "Sign up" : "Log in"
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                finalView.snp.remakeConstraints { make in
                    make.edges.equalTo(self.view)
                }
                
                self.view.layoutIfNeeded()
                finalView.alpha = 1
            }) { _ in }
        }
    }
}


//MARK: - Auth
extension AuthVC {
    @objc private func signupTapped(_ sender: UIButton) {
        guard let email = currentView.emailTF.text, let password = currentView.passwordTF.text else { return }
        
        showOverlay()
        Firebase.shared.signup(withEmail: email, password: password, then: onAuthEnd(success:error:))
    }
    
    @objc private func loginTapped(_ sender: UIButton) {
        guard let email = currentView.emailTF.text, let password = currentView.passwordTF.text else { return }
        
        showOverlay()
        Firebase.shared.signin(withEmail: email, password: password, then: onAuthEnd(success:error:))
    }
    
    private func onAuthEnd(success: Bool, error: Error?) {
        DispatchQueue.main.async {
            guard success, error == nil else {
                self.hideOverlay()
                let ac = UIAlertController(title: "Error authenticating", message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(ac, animated: true)
                return
            }
            
            self.popToRoot()
        }
    }
    
    private func showEmailAlert() {
        currentView.emailTF.becomeFirstResponder()
        
        let ac = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
    
    private func showPasswordAlert() {
        currentView.passwordTF.becomeFirstResponder()
        
        let ac = UIAlertController(title: "Invalid Password", message: "The password you entered is invalid. It must be at least 8 characters long and have at least one lowercase and one uppercase letter. ", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
    
    private func showOverlay() {
        UIView.animate(withDuration: 0.2) {
            self.loadingOverlay.alpha = 1
        }
    }
    
    private func hideOverlay() {
        UIView.animate(withDuration: 0.2) {
            self.loadingOverlay.alpha = 0
        }
    }
}


//MARK: - Navigation
extension AuthVC {
    func popToRoot() {
        navigationController?.viewControllers.insert(RootVC(), at: 0)
        navigationController?.popToRootViewController(animated: true)
    }
}
