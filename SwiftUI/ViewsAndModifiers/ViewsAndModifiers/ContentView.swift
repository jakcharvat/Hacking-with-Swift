//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Jakub Charvat on 17/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("This is my title")
                .largeTitleStyle()
            Text("Normal text comes here")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct LargeTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
}

extension View {
    func largeTitleStyle() -> some View {
        self.modifier(LargeTitleModifier())
    }
}
