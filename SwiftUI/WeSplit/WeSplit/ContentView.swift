//
//  ContentView.swift
//  WeSplit
//
//  Created by Jakub Charvat on 17/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var checkAmount = ""
    @State private var numberOfPeople = ""
    @State private var tipPercentage = 2
    
    let tipPercentages = [10, 15, 20, 25, 0]
    
    var checkTotal: Double {
        let tip = Double(tipPercentages[tipPercentage])
        let amount = Double(checkAmount) ?? 0
        
        let tipAmount = amount / 100 * tip
        let total = amount + tipAmount
        return total
    }
    
    var perPerson: Double {
        let peopleCount = Double(numberOfPeople) ?? 1
        let perPerson = checkTotal / peopleCount
        
        return perPerson
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount", text: $checkAmount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Number of people", text: $numberOfPeople)
                    .navigationBarTitle("WeSplit")
                }
                
                Section(header: Text("How much tip do you want to leave?")) {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(0 ..< tipPercentages.count) {
                            Text("\(self.tipPercentages[$0])%")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Check total")) {
                    Text("$\(String(format: "%.2f", checkTotal))")
                        .foregroundColor(tipPercentage == 4 ? .red : .black)
                }
                
                Section(header: Text("Amount per person")) {
                    Text("$\(String(format: "%.2f", perPerson))")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
