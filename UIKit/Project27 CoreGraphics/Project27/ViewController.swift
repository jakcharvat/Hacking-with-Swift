//
//  ViewController.swift
//  Project27
//
//  Created by Jakub Charvat on 12/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    let size = CGSize(width: 512, height: 512)
    
    var currentDrawIndex = 0 {
        didSet {
            if currentDrawIndex > 7 { currentDrawIndex = 0 }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }
    
    @IBAction func redrawTapped(_: UIButton) {
        currentDrawIndex += 1
        
        switch currentDrawIndex {
        case 0:
            drawRectangle()
            
        case 1:
            drawCircle()
            
        case 2:
            drawCheckerboard()
            
        case 3:
            drawRotatedSquares()
            
        case 4:
            drawLines()
            
        case 5:
            drawImagesAndText()
            
        case 6:
            drawEmoji()
            
        case 7:
            drawTWIN()
            
        default:
            break
        }
    }

}


//MARK: - Rectangle
extension ViewController {
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rect)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
}


//MARK: - Circle
extension ViewController {
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rect)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
}


//MARK: - Checkerboard
extension ViewController {
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            
            let size = CGSize(width: 64, height: 64)
            
            for row in 0..<8 {
                for col in 0..<8 {
                    
                    if (row + col) % 2 == 0 {
                        let origin = CGPoint(x: row * 64, y: col * 64)
                        ctx.cgContext.fill(CGRect(origin: origin, size: size))
                    }
                    
                }
            }
            
        }
        
        imageView.image = img
    }
}


//MARK: - Rotated Squares
extension ViewController {
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 32
            let angle = .pi / Double(rotations * 2)
            
            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(angle))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
}


//MARK: - Lines
extension ViewController {
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let lines = 256
            var isFirst = true
            var lineLength: CGFloat = 256
            
            for _ in 0 ..< lines {
                ctx.cgContext.rotate(by: .pi / 2)
                
                if isFirst {
                    ctx.cgContext.move(to: CGPoint(x: lineLength, y: 50))
                    isFirst = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: lineLength, y: 50))
                }
                
                lineLength *= 0.99
            }
            
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
}


//MARK: - Images and Text
extension ViewController {
    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key : Any] = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 36)
            ]
            
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = img
    }
}


//MARK: - Emoji
extension ViewController {
    func drawEmoji() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            
            guard let bgColor = UIColor(hex: "#FFD52E")?.cgColor,
                let brownColor = UIColor(hex: "#713D0A")?.cgColor,
                let whiteColor = UIColor(hex: "#F1EEEC")?.cgColor else { return }
            
            //MARK: Draw background
            let rect = CGRect(origin: .zero, size: size)
            ctx.cgContext.addEllipse(in: rect)
            ctx.cgContext.setFillColor(bgColor)
            ctx.cgContext.fillPath()
            
            //MARK: Draw eyes
            let eyeRect1 = CGRect(x: 144, y: 160, width: 68, height: 80)
            let eyeRect2 = CGRect(x: 296, y: 160, width: 68, height: 80)
            ctx.cgContext.addEllipse(in: eyeRect1)
            ctx.cgContext.addEllipse(in: eyeRect2)
            ctx.cgContext.setFillColor(brownColor)
            ctx.cgContext.fillPath()
            
            //MARK: Draw mouth
            let mouthPathDef: [[(CGFloat, CGFloat)]] = [
                [(124, 287)],
                [(392, 287)],
                [(430, 335), (416, 287), (430, 311)],
                [(430, 345)],
                [(392, 393), (430, 369), (416, 393)],
                [(124, 393)],
                [(86, 345), (100, 393), (86, 369)],
                [(86, 335)],
                [(124, 287), (86, 311), (100, 287)]
            ]
            for (index, instr) in mouthPathDef.enumerated() {
                if instr.count == 1 {
                    
                    let point = CGPoint(x: instr[0].0, y: instr[0].1)
                    if index == 0 {
                        ctx.cgContext.move(to: point)
                    } else {
                        ctx.cgContext.addLine(to: point)
                    }
                    
                    continue
                }
                
                let points = instr.map { CGPoint(x: $0.0, y: $0.1) }
                ctx.cgContext.addCurve(to: points[0], control1: points[1], control2: points[2])
            }
            
            ctx.cgContext.fillPath()
            
            //MARK: Draw round teeth
            // Format for each instruction: [ arcEnd1, arcEnd2, control1, control2, vertex ]
            let roundTeethDef: [[(CGFloat, CGFloat)]] = [
                [(96, 336), (132, 296), (96, 316), (109, 296), (132, 336)],
                [(384, 296), (420, 336), (407, 296), (420, 316), (384, 336)],
                [(420, 344), (384, 384), (420, 364), (407, 384), (384, 344)],
                [(132, 384), (96, 344), (109, 384), (96, 364), (132, 344)]
            ]
            ctx.cgContext.setFillColor(whiteColor)
            for shape in roundTeethDef {
                let points = shape.map { CGPoint(x: $0.0, y: $0.1) }
                ctx.cgContext.move(to: points[0])
                ctx.cgContext.addCurve(to: points[1], control1: points[2], control2: points[3])
                ctx.cgContext.addLine(to: points[4])
                ctx.cgContext.closePath()
                ctx.cgContext.fillPath()
            }
            
            //MARK: Draw rectangular teeth
            let toothWidth = 58
            let toothHeight = 40
            let toothSpacingX = 4
            let toothSpacingY = 8
            let firstToothX = 136
            let firstToothY = 296
            
            for row in 0..<2 {
                for tooth in 0..<4 {
                    let origin = CGPoint(x: firstToothX + tooth * (toothWidth + toothSpacingX),
                                         y: firstToothY + row * (toothHeight + toothSpacingY))
                    let size = CGSize(width: toothWidth, height: toothHeight)
                    let rect = CGRect(origin: origin, size: size)
                    ctx.cgContext.fill(rect)
                }
            }
        }
        
        imageView.image = img
    }
}


//MARK: - Draw "TWIN"
extension ViewController {
    func drawTWIN() {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            // A definition of the writing. Each 2D array in the 3D array represents a path of lines
            let coords: [[(CGFloat, CGFloat)]] = [
                // T
                [(6, 184), (123, 184)],
                [(65, 184), (65, 330)],
                
                // W
                [(138, 176), (161, 330), (192, 218), (223, 330), (247, 176)],
                
                // I
                [(277, 184), (362, 184)],
                [(321, 184), (321, 322)],
                [(277, 322), (362, 322)],
                
                // N
                [(397, 330), (397, 176), (486, 330), (486, 176)]
            ]
            
            guard let color = UIColor(hex: "#F7B500")?.cgColor else { return }
            
            ctx.cgContext.setLineWidth(20)
            ctx.cgContext.setStrokeColor(color)
            ctx.cgContext.setLineCap(.butt)
            ctx.cgContext.setLineJoin(.bevel)
            for path in coords {
                let points = path.map { CGPoint(x: $0.0, y: $0.1) }
                
                for (index, point) in points.enumerated() {
                    if index == 0 {
                        ctx.cgContext.move(to: point)
                    } else {
                        ctx.cgContext.addLine(to: point)
                    }
                }
                
                ctx.cgContext.strokePath()
            }
        }
        
        imageView.image = img
    }
}
