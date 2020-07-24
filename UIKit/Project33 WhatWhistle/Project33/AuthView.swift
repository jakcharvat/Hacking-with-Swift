//
//  AuthView.swift
//  Project33
//
//  Created by Jakub Charvat on 21/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class AuthView: UIView {
    
    private var loginStack: UIStackView!
    private(set) var emailTF: UITextField!
    private(set) var passwordTF: UITextField!
    private(set) var secondaryButton: UIButton!
    private(set) var mainButton: UIButton!
    
    private var isEmailValid = false
    private var isPasswordValid = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createAuthForm()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func createAuthForm() {
        //MARK: Views
        let emailLabel = UILabel()
        emailLabel.text = "Email:"
        emailLabel.font = .preferredFont(forTextStyle: .caption1)
        
        emailTF = UITextField()
        emailTF.placeholder = "johndoe@example.com"
        emailTF.borderStyle = .roundedRect
        emailTF.autocorrectionType = .no
        emailTF.autocapitalizationType = .none
        emailTF.keyboardType = .emailAddress
        emailTF.textContentType = .emailAddress
        emailTF.delegate = self
        emailTF.returnKeyType = .done
        emailTF.addTarget(self, action: #selector(emailDidChange(_:)), for: .editingChanged)
        
        let emailContainer = TextFieldContainer()
        emailContainer.label = emailLabel
        emailContainer.textField = emailTF
        emailContainer.configure()
        
        let passwordLabel = UILabel()
        passwordLabel.text = "Password:"
        passwordLabel.font = .preferredFont(forTextStyle: .caption1)
        
        passwordTF = UITextField()
        passwordTF.borderStyle = .roundedRect
        passwordTF.placeholder = "kSNJgabKmD8bPyvV"
        passwordTF.isSecureTextEntry = true
        passwordTF.textContentType = .password
        passwordTF.delegate = self
        passwordTF.returnKeyType = .done
        passwordTF.addTarget(self, action: #selector(passwordDidChange(_:)), for: .editingChanged)
        
        let passwordContainer = TextFieldContainer()
        passwordContainer.label = passwordLabel
        passwordContainer.textField = passwordTF
        passwordContainer.configure()
        
        mainButton = UIButton()
        mainButton.backgroundColor = .systemBlue
        mainButton.setTitleColor(.white, for: .normal)
        mainButton.layer.cornerRadius = 10
        mainButton.addTarget(self, action: #selector(touchStart(_:)), for: .touchDown)
        mainButton.addTarget(self, action: #selector(touchEnd(_:)), for: [ .touchUpInside, .touchDragExit ])
        mainButton.isEnabled = false
        mainButton.alpha = 0.5
        
        secondaryButton = UIButton()
        secondaryButton.layer.cornerRadius = 10
        secondaryButton.setTitleColor(.systemBlue, for: .normal)
        secondaryButton.addTarget(self, action: #selector(touchStart(_:)), for: .touchDown)
        secondaryButton.addTarget(self, action: #selector(touchEnd(_:)), for: [ .touchUpInside, .touchDragExit ])
        
        let buttonsRow = UIStackView(arrangedSubviews: [ secondaryButton, mainButton ])
        buttonsRow.distribution = .fill
        buttonsRow.spacing = 20
        
        let spacer1 = UIView(frame: .infinite)
        let spacer2 = UIView(frame: .infinite)
        loginStack = UIStackView(arrangedSubviews: [ spacer1, emailContainer, passwordContainer, spacer2, buttonsRow ])
        loginStack.axis = .vertical
        loginStack.spacing = 30
        
        self.addSubview(loginStack)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: Constraints
        loginStack.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(self).inset(10).priority(.high)
            make.width.lessThanOrEqualTo(400)
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
        
        emailContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(loginStack)
        }

        passwordContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(loginStack)
        }
        
        mainButton.snp.makeConstraints { make in
            make.height.equalTo(emailTF)
            make.height.equalTo(passwordTF)
            make.height.equalTo(secondaryButton)
            make.height.equalTo(44)
            
            make.width.equalTo(secondaryButton).multipliedBy(3)
        }
        
        spacer1.snp.makeConstraints { make in
            make.height.equalTo(spacer2)
        }
    }
}


//MARK: - Button Touches
extension AuthView {
    @objc func touchStart(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) { sender.alpha = 0.5 }
    }
    
    @objc func touchEnd(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) { sender.alpha = 1 }
    }
}


//MARK: - TF Delegate
extension AuthView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


//MARK: - Validation
extension AuthView {
    @objc private func emailDidChange(_ sender: UITextField) {
        isEmailValid = validateEmail(sender.text)
        showValidation()
    }
    
    @objc private func passwordDidChange(_ sender: UITextField) {
        isPasswordValid = validatePassword(sender.text)
        showValidation()
    }
    
    func validateAll() {
        emailDidChange(emailTF)
        passwordDidChange(passwordTF)
    }
    
    private func showValidation() {
        emailTF.textColor = isEmailValid ? .label : .systemRed
        passwordTF.textColor = isPasswordValid ? .label : .systemRed
        
        let canAuth = isEmailValid && isPasswordValid
        mainButton.isEnabled = canAuth
        
        UIView.animate(withDuration: 0.1) {
            self.mainButton.alpha = canAuth ? 1 : 0.5
        }
    }
    
    
    private func validateEmail(_ email: String?) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    private func validatePassword(_ password: String?) -> Bool {
        guard let password = password else { return false }
        guard password.count >= 8 else { return false }
        guard password.lowercased() != password && password.uppercased() != password else { return false }
        
        return true
    }
}


//MARK: - Keyboard Frame
extension AuthView {
    @objc private func keyboardFrameChanged(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = convert(keyboardScreenEndFrame, from: window)
        
        let keyboardPadding: CGFloat = 10
        let keyboardShift = max(frame.size.height - keyboardViewEndFrame.origin.y - safeAreaInsets.bottom, 0)
        let offset = keyboardShift + keyboardPadding
        
        loginStack.snp.remakeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).labeled("remakeTop")
            make.bottom.equalTo(safeAreaLayoutGuide).inset(offset).labeled("remakeBottom")
            make.centerX.equalTo(self).labeled("remakeCenterX")
            make.width.equalTo(self).inset(10).priority(.high).labeled("remakeWidthEqual")
            make.width.lessThanOrEqualTo(400).labeled("remakeWidthLessThan")
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}
