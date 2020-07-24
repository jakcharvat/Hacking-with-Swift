//
//  JumpingLetters.swift
//  Animations
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct JumpingLetters: View {
    let letters = Array("Hello SwiftUI")
    
    @State private var enabled = false
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< letters.count) { i in
                Text(String(self.letters[i]))
                    .padding(5)
                    .font(.title)
                    .background(self.enabled ? Color.blue : Color.red)
                    .offset(self.dragAmount)
                    .animation(Animation.default.delay(Double(i) / 20))
            }
        }
        .gesture(
            DragGesture()
                .onChanged { self.dragAmount = $0.translation }
                .onEnded { _ in
                    self.dragAmount = .zero
                    self.enabled.toggle()
                }
        )
    }
}

struct JumpingLetters_Previews: PreviewProvider {
    static var previews: some View {
        JumpingLetters()
    }
}
