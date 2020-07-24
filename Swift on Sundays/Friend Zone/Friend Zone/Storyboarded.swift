//
//  Storyboarded.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}


extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let className = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
