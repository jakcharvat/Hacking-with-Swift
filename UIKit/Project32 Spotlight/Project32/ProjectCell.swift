//
//  ProjectCell.swift
//  Project32
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class ProjectCell: UITableViewCell {
    
    var textView: UILabel!
    var favouriteButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createTextView()
        createFavouriteButton()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    
    private func createTextView() {
        textView = UILabel()
        textView.numberOfLines = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        addSubview(textView)
    }
    
    private func createFavouriteButton() {
        favouriteButton = UIButton()
        favouriteButton.tintColor = .systemYellow
        favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favouriteButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        favouriteButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        addSubview(favouriteButton)
    }
    
    private func configureConstraints() {
        textView.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalTo(self).inset(10)
            make.trailing.equalTo(favouriteButton.snp.leading).inset(-10)
        }
        
        favouriteButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(textView)
            make.trailing.equalTo(self).inset(10)
        }
    }
}
