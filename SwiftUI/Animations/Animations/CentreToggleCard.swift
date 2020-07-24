//
//  CentreToggleCard.swift
//  Animations
//
//  Created by Jakub Charvat on 18/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SwiftUI

struct CentreToggleCard: View {
    
    private var isOn: Binding<Bool>
    private var label: String
    
    private let backgroundColor: Color
    private let fillColor: Color
    private let animation: Animation
    
    init(label: String, isOn: Binding<Bool>, backgroundColor: Color = Color(UIColor.systemBackground), fillColor: Color = Color(UIColor.systemBlue), animation: Animation = .easeInOut) {
        self.isOn = isOn
        self.label = label
        
        self.backgroundColor = backgroundColor
        self.fillColor = fillColor
        self.animation = animation
    }
    
    var body: some View {
        GeometryReader { (gr: GeometryProxy) in
            ZStack {
                self.fillColor
                    .frame(width: self.getRadius(from: gr) * 2, height: self.getRadius(from: gr) * 2)
                    .clipShape(Circle())
                    .scaleEffect(self.isOn.wrappedValue ? 1 : 0)
                    .animation(self.animation)
                    .frame(width: gr.size.width, height: gr.size.height)
                    .clipped()

                Toggle(isOn: self.isOn) {
                    Text(self.label)
                }
                .labelsHidden()
            }
            .frame(width: gr.size.width, height: gr.size.height)
        }
        .cornerRadius(10)
        .background(Rectangle()
            .fill(backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 10)
        )
    }
    
    func getRadius(from gr: GeometryProxy) -> CGFloat {
        let size = gr.size
        let dx = size.width / 2
        let dy = size.height / 2
        
        let radius = sqrt(dx * dx + dy * dy)
        return radius
    }
}

struct CentreToggleCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                Text("Light Appearance")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .previewDisplayName(" ")
                    .previewLayout(.sizeThatFits)
                
                CentreToggleCard(label: "Label", isOn: .constant(false))
                    .previewDisplayName("OFF")
                
                CentreToggleCard(label: "Label", isOn: .constant(true))
                    .previewDisplayName("ON")
            }
            Group {
                Text("Dark Appearance")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .previewLayout(.sizeThatFits)
                    .previewDisplayName(" ")
                
                CentreToggleCard(label: "Label", isOn: .constant(false))
                    .previewDisplayName("OFF")
                
                CentreToggleCard(label: "Label", isOn: .constant(true))
                    .previewDisplayName("ON")
            }
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }
}
