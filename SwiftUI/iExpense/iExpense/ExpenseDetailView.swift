//
//  ExpenseDetailView.swift
//  iExpense
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ExpenseDetailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let expense: ExpenseItem
    let onDelete: (ExpenseItem) -> ()
    
    var body: some View {
        Form {
            Section(header: Text("Expense Details")) {
                ExpenseDetailItem(title: "Name", value: expense.name)
                ExpenseDetailItem(title: "Category", value: expense.type.rawValue)
                ExpenseDetailItem(title: "Amount", value: "\(String(format: "$%.2f", expense.amount))")
            }
            
            Section(header: Text("Actions")) {
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        self.onDelete(self.expense)
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView(expense: ExpenseItem(name: "Test", type: .Personal, amount: 12.0)) { _ in }
    }
}

fileprivate struct ExpenseDetailItem: View {
    
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(title):")
                .font(.headline)
            Text(value)
            Spacer()
        }
    }
}
