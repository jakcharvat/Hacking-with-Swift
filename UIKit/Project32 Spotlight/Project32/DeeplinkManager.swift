//
//  DeeplinkManager.swift
//  Project32
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation


class DeeplinkManager {
    static let shared = DeeplinkManager()
    
    var activeDeeplink: String?
    
    func registerDeeplink(identifier: String) {
        guard activeDeeplink == nil else { return }
        
        activeDeeplink = identifier
    }
    
    func openDeeplink(with rootvc: ViewController) {
        guard let deeplink = activeDeeplink else { return }
        
        if let url = URL(string: deeplink) {
            rootvc.showTutorial(at: url)
        }
        
        activeDeeplink = nil
    }
}
