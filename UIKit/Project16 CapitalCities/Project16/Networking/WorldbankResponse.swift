//
//  WorldbankResponse.swift
//  Project16
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct WorldbankCountry: Codable {
    let capitalCity: String
    let latitude: String
    let longitude: String
}

struct WorldbankMeta: Codable {
    let total: Int
}
