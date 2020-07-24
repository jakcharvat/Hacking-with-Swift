//
//  LoadingOverlay.swift
//  Project33
//
//  Created by Jakub Charvat on 21/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class LoadingOverlay: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        create()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func create() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .label
        addSubview(activityIndicator)
        
        backgroundColor = .clear
        
        translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        
        activityIndicator.startAnimating()
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurView, at: 0)
        
        blurView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
