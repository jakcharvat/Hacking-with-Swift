//
//  Order.swift
//  App
//
//  Created by Jakub Charvat on 29/05/2020.
//

import FluentSQLite
import Vapor

struct Order: Content, SQLiteModel, Migration {
    var id: Int?
    let cakeName: String
    let buyerName: String
    var date: Date?
}
