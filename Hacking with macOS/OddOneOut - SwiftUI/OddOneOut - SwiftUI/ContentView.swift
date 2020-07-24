//
//  ContentView.swift
//  OddOneOut - SwiftUI
//
//  Created by Jakub Charvat on 03/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    static let gridSize = 10
    
    @State private var images = [ "elephant", "giraffe", "hippo", "monkey", "panda", "parrot", "penguin", "pig", "rabbit", "snake" ]
    @State private var layout = (1...100).map { _ in "" }
    @State private var currentLevel = 1
    @State private var isGameOver = false
    
    @State private var isHidden = true
    
    var body: some View {
        ZStack {
            VStack {
                Text("Odd One Out")
                    .font(.largeTitle)
                    .fontWeight(.thin)
                    .padding(.bottom, 10)
                
                ForEach(0 ..< Self.gridSize, id: \.self) { row in
                    HStack {
                        ForEach(0 ..< Self.gridSize, id: \.self) { col in
                            VStack {
                                if self.image(for: row, col).isEmpty {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 64, height: 64)
                                } else {
                                    Button(action: {
                                        self.processAnswer(at: row, col)
                                    }) {
                                        Image(self.image(for: row, col))
                                            .renderingMode(.original)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .id(self.image(for: row, col))
                            .onTapGesture {
                                print(self.image(for: row, col))
                            }
                        }
                    }
                }
            }
            .opacity(isGameOver ? 0.4 : 1)
            
            if isGameOver {
                VStack {
                    Text("Game over!")
                        .font(.largeTitle)

                    Button("Play Again") {
                        self.currentLevel = 1
                        self.isGameOver = false
                        self.createLevel()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(20)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
            }
        }
        .opacity(isHidden ? 0 : 1)
        .animation(.easeOut)
        .onAppear {
            self.createLevel()
            self.isHidden = false
        }
        .contextMenu {
            Button("Play Again") {
                self.currentLevel = 1
                self.isGameOver = false
                self.createLevel()
            }
        }
    }
    
    
    private func image(for row: Int, _ col: Int) -> String {
        let index = row * 10 + col
        let string = layout[index]
        
        return string
    }
    
    
    private func generateLayout(items: Int) {
        // remove any existing layouts
        layout.removeAll(keepingCapacity: true)

        // randomize the image order, and consider the first image to be the correct animal
        images.shuffle()
        layout.append(images[0])

        // prepare to loop through the other animals
        var numUsed = 0
        var itemCount = 1

        for _ in 1 ..< items {
            // place the current animal image and add to the counter
            layout.append(images[itemCount])
            numUsed += 1

            // if we already placed two, move to the next animal image
            if (numUsed == 2) {
                numUsed = 0
                itemCount += 1
            }

            // if we placed all the animal images, go back to index 1.
            if (itemCount == images.count) {
                itemCount = 1
            }
        }

        // fill the remainder of our array with empty rectangles then shuffle the layout
        layout += Array(repeating: "", count: 100 - layout.count)
        layout.shuffle()
    }

    private func createLevel() {
        if currentLevel == 9 {
            withAnimation {
                isGameOver = true
            }
        } else {
            let numbersOfItems = [0, 5, 15, 25, 35, 49, 65, 81, 100]
            generateLayout(items: numbersOfItems[currentLevel])
        }
    }

    private func processAnswer(at row: Int, _ column: Int) {
        if self.image(for: row, column) == self.images[0] {
            // they clicked the correct animal
            self.currentLevel += 1
            self.createLevel()
        } else {
            // they clicked the wrong animal
            if self.currentLevel > 1 {
                // take the current level down by 1 if we can
                self.currentLevel -= 1
            }

            // create a new layout
            self.createLevel()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
