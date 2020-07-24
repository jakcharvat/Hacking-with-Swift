//
//  AddExpenseView.swift
//  iExpense
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct AddExpenseView: View {
    
    @ObservedObject var expenseModel: ExpenseModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                
                Picker("Type", selection: $type) {
                    ForEach(ExpenseType.allCases) { type in
                        Text(type.rawValue)
                    }
                }
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationBarTitle("Add new expense")
            .navigationBarItems(trailing: Button("Save") {
                if let amount = Double(self.amount.replacingOccurrences(of: ",", with: ".")), let type = ExpenseType(rawValue: self.type) {
                    let item = ExpenseItem(name: self.name, type: type, amount: amount)
                    self.expenseModel.expenses.append(item)
                    self.expenseModel.save()
                    self.presentationMode.wrappedValue.dismiss()
                    return
                }
                
                self.alertTitle = "Invalid Price"
                self.alertMessage = "You entered an invalid price. Please enter it as a decimal number, with no currency indicator, and using a dot (.) or a comma (,) as the decimal delimiter."
                self.showingAlert = true
                
            })
        }
        .alert(isPresented: $showingAlert) { () -> Alert in
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("Okay")))
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(expenseModel: ExpenseModel())
    }
}
