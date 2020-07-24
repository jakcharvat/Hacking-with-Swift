//
//  BuildingNode.swift
//  Project29
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!
}
 

//MARK: - Setup
extension BuildingNode {
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
}


//MARK: - Physics
extension BuildingNode {
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
}


//MARK: - Drawing
extension BuildingNode {
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let color: UIColor
            
            switch Int.random(in: 1...3) {
            case 1:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 2:
                color = UIColor(hue: 0.999, saturation: 0.98, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()
            ctx.cgContext.addRect(rect)
            ctx.cgContext.drawPath(using: .fill)
            
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)

            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    let rect = CGRect(x: col, y: row, width: 15, height: 20)
                    ctx.cgContext.fill(rect)
                    
                }
            }
            
        }
        
        return img
    }
}


//MARK: - Hit
extension BuildingNode {
    func hit(at impactPoint: CGPoint) {
        let cgImpactPoint = CGPoint(x: impactPoint.x + size.width / 2, y: abs(impactPoint.y - size.height / 2))
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            currentImage.draw(at: .zero)
            
            let holeOrigin = CGPoint(x: cgImpactPoint.x - 32, y: cgImpactPoint.y - 32)
            let holeSize = CGSize(width: 64, height: 64)
            
            ctx.cgContext.addEllipse(in: CGRect(origin: holeOrigin, size: holeSize))
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        
        configurePhysics()
        
    }
}
