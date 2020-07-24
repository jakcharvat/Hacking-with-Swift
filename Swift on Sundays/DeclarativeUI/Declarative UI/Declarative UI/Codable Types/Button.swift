//
//  Button.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Button: Decodable, HasAction {
    let title: String
    var action: Action?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionCodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        action = try decodeAction(from: container)
    }
}
