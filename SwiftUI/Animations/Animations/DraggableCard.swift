//
//  DraggableCard.swift
//  Animations
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct DraggableCard: View {
    
    @State private var dragAmount = CGSize.zero
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [ .yellow, .red ]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: 300, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
            .offset(dragAmount)
            .animation(.spring())
            .gesture(DragGesture()
                .onChanged { self.dragAmount = $0.translation }
                .onEnded { _ in self.dragAmount = .zero }
        )
    }
}

struct DraggableCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                DraggableCard()
                    .navigationBarTitle("Draggable Card")
            }
            .previewDisplayName("Light")
            
            NavigationView {
                DraggableCard()
                .navigationBarTitle("Draggable Card")
            }
            .environment(\.colorScheme, .dark)
            .previewDisplayName("Dark")
        }
    }
}
