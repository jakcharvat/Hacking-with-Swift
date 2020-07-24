//
//  WhistleManager.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

class WhistleManager {
    private(set) var whistles = [Whistle]()
    weak var delegate: WhistleManagerDelegate?
    
    func loadWhistles() {
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = UserDefaults.standard.data(forKey: "whistles") {
                if let whistles = try? JSONDecoder().decode([Whistle].self, from: data) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.whistles = whistles
                        self.delegate?.whistleManager(self, didLoadWhistles: whistles)
                    }
                    return
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.whistleManagerDidFailFetchingWhistles(self)
            }
        }
    }
    
    func addWhistle(_ whistle: Whistle) -> Bool {
        whistles.append(whistle)
        return saveWhistles(whistles)
    }
    
    private func saveWhistles(_ whistles: [Whistle]) -> Bool {
        if let data = try? JSONEncoder().encode(whistles) {
            UserDefaults.standard.set(data, forKey: "whistles")
            return true
        }
        
        return false
    }
}


protocol WhistleManagerDelegate: class {
    func whistleManager(_ whistleManager: WhistleManager, didLoadWhistles: [Whistle])
    func whistleManagerDidFailFetchingWhistles(_ whistleManager: WhistleManager)
}
