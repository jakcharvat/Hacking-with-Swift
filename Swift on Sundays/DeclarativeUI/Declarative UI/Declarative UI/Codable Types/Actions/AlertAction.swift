//
//  AlertAction.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct AlertAction: Action {
    let title: String
    let message: String
    
    let presentsNewScreen = false
}
