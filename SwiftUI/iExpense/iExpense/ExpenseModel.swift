//
//  ExpenseModel.swift
//  iExpense
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

class ExpenseModel: ObservableObject {
    @Published var expenses: [ExpenseItem] {
        didSet {
            print("Save")
            save()
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "Expenses")
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "Expenses") {
            let decoder = JSONDecoder()
            if let expenses = try? decoder.decode([ExpenseItem].self, from: data) {
                self.expenses = expenses
                return
            }
        }
        
        self.expenses = []
    }
}
