//
//  Whistle.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Whistle: Codable {
    let genre: Genre
    let comments: String
    let id: String
}


enum Genre: String, CaseIterable, Codable {
    case Unknown
    case Blues
    case Classical
    case Electronic
    case Jazz
    case Metal
    case Pop
    case Reggae
    case RnB
    case Rock
    case Soul
}
