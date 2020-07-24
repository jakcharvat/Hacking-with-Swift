//
//  ContentView.swift
//  GessTheFlag
//
//  Created by Jakub Charvat on 17/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingScore = false
    @State private var alert = Alert(title: Text(""))
    @State private var score = 0
    @State private var countries = [ "Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US" ].shuffled()
    @State private var correctIndex = Int.random(in: 0...2)
    
    @State private var flagRotations = [ 0.0, 0.0, 0.0 ]
    @State private var flagOpacities = [ 1.0, 1.0, 1.0 ]
    @State private var flagOffsets: [CGSize] = [ .zero, .zero, .zero ]
    @State private var flagScales: [CGFloat] = [ 1, 1, 1 ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [ .blue, .black ]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                VStack {
                    Text("Tap the flag of")
                        .padding(.top)
                    Text(countries[correctIndex])
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                .foregroundColor(.white)
                
                Spacer()
                
                ForEach(0 ..< 3) { i in
                    FlagImage(countries: self.countries, countryIndex: i) {
                        self.flagTapped(at: i)
                    }
                    .rotation3DEffect(.degrees(self.flagRotations[i]), axis: (x: 0, y: 1, z: 0))
                    .opacity(self.flagOpacities[i])
                    .offset(self.flagOffsets[i])
                    .scaleEffect(self.flagScales[i])
                }
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom)
            }
        }
        .alert(isPresented: $showingScore, content: { alert })
    }
    
    
    private func flagTapped(at index: Int) {
        if index == correctIndex {
            score += 1
            alert = Alert(title: Text("Correct!"), message: Text("Your score is \(score)"), dismissButton: .default(Text("Continue"), action: {
                self.askQuestion()
            }))
            withAnimation {
                flagRotations[index] = 360
                
                switch index {
                case 0:
                    flagOpacities = [ 1, 0.25, 0.25 ]
                case 1:
                    flagOpacities = [ 0.25, 1, 0.25 ]
                case 2:
                    flagOpacities = [ 0.25, 0.25, 1 ]
                default:
                    break
                }
                
            }
        } else {
            alert = Alert(title: Text("Wrong!"), message: Text("You tapped the flag of \(countries[index])"), dismissButton: .default(Text("Continue"), action: {
                self.askQuestion()
            }))
            
            withAnimation(.easeInOut(duration: 0.07)) {
                flagOffsets[index] = CGSize(width: 20, height: 0)
            }
            
            withAnimation {
                flagScales[correctIndex] = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 500, damping: 15)) {
                    self.flagOffsets[index] = .zero
                }
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showingScore = true
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctIndex = Int.random(in: 0...2)
        flagRotations = [ 0, 0, 0 ]
        flagOpacities = [ 1, 1, 1 ]
        flagScales = [ 1, 1, 1 ]
        flagOffsets = [ .zero, .zero, .zero ]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct FlagImage: View {
    
    let countries: [String]
    let countryIndex: Int
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            Image(self.countries[countryIndex])
                .renderingMode(.original)
        }
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.black, lineWidth: 1))
        .shadow(color: .black, radius: 2)
    }
}
