//
//  MapTypePicker.swift
//  Project16
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

//MARK: - Properties & Init
class MapTypePicker: UIControl {
    
    private let moveDuration = 0.5
    
    private let backgroundPaddingVertical: CGFloat = 5
    private let backgroundPaddingHorizontal: CGFloat = 20
    private let pillPaddingVertical: CGFloat = 0
    private let pillPaddingHorizontal: CGFloat = 15
    
    private let types: [String]
    
    private var buttons: [UIButton] = []
    private var buttonsStack: UIStackView!
    private var background: UIView!
    private var pill: UIView!
    private var pillPositionConstraints: [NSLayoutConstraint] = []
    
    private let blurEffect = UIBlurEffect(style: .systemMaterial)
    private var backgroundBlurView: UIVisualEffectView!
    
    private var _selectedItemIndex: Int
    
    var selectedItemLabel: String {
        types[_selectedItemIndex]
    }
    var selectedItemIndex: Int {
        _selectedItemIndex
    }
    
    
    init(types: [String], initialSelectionIndex: Int = 0) {
        self.types = types
        _selectedItemIndex = initialSelectionIndex
        
        super.init(frame: .zero)
        
        createBackground()
        createPill()
        createButtons()
        createBlur()
        
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}


//MARK: - Lifecycle
extension MapTypePicker {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureLayers()
        updatePillPosition(animated: false)
    }
}


//MARK: - Background
extension MapTypePicker {
    private func createBackground() {
        background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .clear
        addSubview(background)
    }
}


//MARK: - Blur
extension MapTypePicker {
    private func createBlur() {
        backgroundBlurView = UIVisualEffectView(effect: blurEffect)
        backgroundBlurView.clipsToBounds = true
        background.insertSubview(backgroundBlurView, at: 0)
    }
}


//MARK: - Labels
extension MapTypePicker {
    private func createButtons() {
        
        buttons = types.enumerated().map { (index, type) in
            let button = UIButton()
            button.setTitle(type, for: .normal)
            button.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16, weight: .medium))
            button.contentEdgeInsets = .zero
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            button.setTitleColor(index == _selectedItemIndex ? .white : .systemGray, for: .normal)
            
            return button
        }
        
        buttonsStack = UIStackView(arrangedSubviews: buttons)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.spacing = 30
        
        addSubview(buttonsStack)
    }
}


//MARK: - Indicator Pill
extension MapTypePicker {
    private func createPill() {
        pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor.systemGray.withAlphaComponent(0.7)
        addSubview(pill)
    }
}


//MARK: - Layers
extension MapTypePicker {
    private func configureLayers() {
        background.layer.cornerRadius = frame.height / 2
        pill.layer.cornerRadius = pill.frame.height / 2
        backgroundBlurView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        backgroundBlurView.layer.cornerRadius = frame.height / 2
    }
}


//MARK: - Constraints
extension MapTypePicker {
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.topAnchor.constraint(equalTo: topAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            background.leadingAnchor.constraint(equalTo: buttonsStack.leadingAnchor, constant: -backgroundPaddingHorizontal),
            background.topAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -backgroundPaddingVertical),
            background.trailingAnchor.constraint(equalTo: buttonsStack.trailingAnchor, constant: backgroundPaddingHorizontal),
            background.bottomAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: backgroundPaddingVertical),
            
            pill.topAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -pillPaddingVertical),
            pill.bottomAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: pillPaddingVertical),
        ])
    }
    
    private func updatePillPosition(animated: Bool = true) {
        guard _selectedItemIndex < buttons.count else { return }
        
        let selectedButton = buttons[_selectedItemIndex]
        
        NSLayoutConstraint.deactivate(pillPositionConstraints)
        pillPositionConstraints = [
            pill.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor, constant: -pillPaddingHorizontal),
            pill.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor, constant: pillPaddingHorizontal),
        ]
        NSLayoutConstraint.activate(pillPositionConstraints)
        
        if animated {
            springAnimate { self.layoutIfNeeded() }
        } else { layoutIfNeeded() }
    }
}


//MARK: - Tap Handling
extension MapTypePicker {
    @objc private func buttonTapped(_ sender: UIButton) {
        guard buttons.contains(sender) else { return }
        
        for button in buttons {
            let color: UIColor = button == sender ? .white : .systemGray
            if button.titleLabel?.textColor == color { continue }
            
            UIView.transition(with: button, duration: moveDuration, options: .transitionCrossDissolve, animations: {
                button.setTitleColor(color, for: .normal)
            })
        }
        
        _selectedItemIndex = sender.tag
        updatePillPosition()
        
        sendActions(for: .valueChanged)
    }
}


//MARK: - Animations
extension MapTypePicker {
    private func springAnimate(animations: @escaping () -> Void) {
        UIView.animate(withDuration: moveDuration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2, options: [], animations: animations)
    }
}
