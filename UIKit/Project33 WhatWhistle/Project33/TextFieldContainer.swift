//
//  TextfieldContainer.swift
//  Project33
//
//  Created by Jakub Charvat on 21/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class TextFieldContainer: UIView {
    var textField: UITextField!
    var label: UILabel!
    
    func configure() {
        addSubview(textField)
        addSubview(label)
        
        snp.makeConstraints { make in
            make.top.equalTo(label)
            make.bottom.equalTo(textField)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(self).inset(4)
            make.bottom.equalTo(textField.snp.top).inset(-10)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
        }
    }
}
