//
//  Cupcake.swift
//  App
//
//  Created by Jakub Charvat on 29/05/2020.
//

import Vapor
import FluentSQLite

struct Cupcake: Content, SQLiteModel, Migration {
    var id: Int?
    let name: String
    let description: String
    let price: Int
}
