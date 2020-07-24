//
//  ViewCounter.swift
//  Project1
//
//  Created by Jakub Charvat on 29/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct ViewCounter: Codable {
    
    private var views: [String: Int] {
        didSet {
            save()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.object(forKey: "views") as? Data {
            if let views = try? JSONDecoder().decode([String: Int].self, from: data) {
                self.views = views
                return
            }
        }
        
        self.views = [:]
    }
    
    mutating func view(image: String) {
        views[image, default: 0] += 1
    }
    
    func views(for image: String) -> Int {
        return views[image, default: 0]
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(views) else { return }
        UserDefaults.standard.set(data, forKey: "views")
    }
}
