//
//  ShareAction.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct ShareAction: Action {
    let text: String?
    let url: URL?
    
    let presentsNewScreen = false
}
