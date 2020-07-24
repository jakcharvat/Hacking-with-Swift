//
//  ContentView.swift
//  iExpense
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var expenseModel = ExpenseModel()
    
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ExpenseType.allCases) { type in
                    Section(header: Text(type.rawValue)) {
                        ForEach(self.expenseModel.expenses.filter { $0.type == type }) { (expense: ExpenseItem) in
                            NavigationLink(destination: ExpenseDetailView(expense: expense) { expense in
                                if let index = self.expenseModel.expenses.firstIndex(where: { $0.id == expense.id }) {
                                    self.expenseModel.expenses.remove(at: index)
                                    self.expenseModel.save()
                                }
                            }) {
                                Text(expense.name)
                                    .font(.headline)
                            }
                        }
                        .onDelete(perform: self.removeItems(at:))
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton() ,trailing: Button(action: {
                self.showingAddExpense = true
            }) {
                Image(systemName: "plus")
            })
        }.sheet(isPresented: $showingAddExpense) {
            AddExpenseView(expenseModel: self.expenseModel)
        }
    }
    
    
    func removeItems(at offsets: IndexSet) {
        expenseModel.expenses.remove(atOffsets: offsets)
        expenseModel.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
