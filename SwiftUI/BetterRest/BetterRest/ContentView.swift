//
//  ContentView.swift
//  BetterRest
//
//  Created by Jakub Charvat on 17/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUp = ContentView.defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    let model: SleepCalculator = {
        do {
            let config = MLModelConfiguration()
            return try SleepCalculator(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SleepCalculator")
        }
    }()
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var bedtime: String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 3600
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let bedTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: bedTime)
        } catch {
            return "Error predicting bedtime"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("When do you want to wake up?")) {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Section(header: Text("Desired amount of sleep")) {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }
                    }
                    
                    Section(header: Text("Daily coffee intake")) {
                        Stepper(value: $coffeeAmount, in: 0...20) {
                            if coffeeAmount == 1 {
                                Text("1 cup")
                            } else {
                                Text("\(coffeeAmount) cups")
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Suggested Bedtime:")
                        .font(.caption)
                        .padding(.leading)
                        .foregroundColor(Color.secondary)
                    Spacer()
                }
                    
                Spacer().frame(height: 10)
                
                Text(bedtime)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
            }
            .navigationBarTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
