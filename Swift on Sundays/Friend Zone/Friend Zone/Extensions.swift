//
//  Extensions.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

//MARK: - Int
extension Int {
    func timeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .hour, .minute ]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(self)) ?? "0"
        
        if formattedString.contains("-") {
            return "GMT\(formattedString)"
        }
        
        return "GMT+\(formattedString)"
    }
}


extension TimeZone {
    var formattedIdentifier: String {
        return identifier.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "/", with: " / ")
    }
}
