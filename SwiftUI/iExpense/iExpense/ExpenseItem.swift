//
//  ExpenseItem.swift
//  iExpense
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct ExpenseItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: ExpenseType
    let amount: Double
}


enum ExpenseType: String, CaseIterable, Codable {
    case Personal
    case Business
}

extension ExpenseType: Identifiable {
    var id: String { rawValue }
}
