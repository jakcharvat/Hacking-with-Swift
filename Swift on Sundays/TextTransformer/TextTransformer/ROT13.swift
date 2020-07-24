//
//  ROT13.swift
//  TextTransformer
//
//  Created by Jakub Charvat on 29/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation


struct ROT13 {
    private static var key = [Character : Character]()
    
    private static let uppercase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private static let lowercase = Array("abcdefghijklmnopqrstuvwxyz")
    
    static func string(_ string: String) -> String {
        if key.isEmpty {
            for i in 0 ..< lowercase.count {
                key[lowercase[i]] = lowercase[(i + lowercase.count / 2) % lowercase.count]
            }
            
            for i in 0 ..< uppercase.count {
                key[uppercase[i]] = uppercase[(i + uppercase.count / 2) % uppercase.count]
            }
        }
        
        let transformed = string.map { key[$0, default: $0] }
        
        return String(transformed)
    }
}
