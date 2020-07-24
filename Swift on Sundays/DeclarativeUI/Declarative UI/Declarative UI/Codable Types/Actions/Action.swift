//
//  Action.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

protocol Action: Decodable {
    var presentsNewScreen: Bool { get }
}


enum ActionCodingKeys: String, CodingKey {
    case title
    case actionType
    case action
}
