//
//  Exponentiation.swift
//  Project26
//
//  Created by Jakub Charvat on 12/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import CoreGraphics

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func ** (_ base: Int, _ exponent: Int) -> Int {
    Int(pow(Double(base), Double(exponent)))
}

func ** (_ base: Double, _ exponent: Double) -> Double {
    pow(base, exponent)
}

func ** (_ base: Float, _ exponent: Float) -> Float {
    powf(base, exponent)
}

func ** (_ base: CGFloat, _ exponent: CGFloat) -> CGFloat {
    pow(base, exponent)
}
