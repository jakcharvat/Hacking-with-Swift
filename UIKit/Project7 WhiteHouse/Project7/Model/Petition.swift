//
//  Petition.swift
//  Project7
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Petition: Codable {
    let title: String
    let body: String
    let signatureCount: Int
}
