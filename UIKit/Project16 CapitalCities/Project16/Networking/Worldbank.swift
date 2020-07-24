//
//  Worldbank.swift
//  Project16
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Worldbank {
    
    static private let baseURL = "https://api.worldbank.org/v2/country"
    
    static func getCapitals(perPage: Int? = nil, then handler: @escaping ([WorldbankCountry]) -> Void) {
        
        let urlString = "\(baseURL)?format=json&per_page=\(perPage ?? 1)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print(error ?? "No data received")
                return
            }
            
            guard let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                let metaData = try? JSONSerialization.data(withJSONObject: decoded[0], options: []),
                let meta = try? JSONDecoder().decode(WorldbankMeta.self, from: metaData) else { return }
            
            let total = meta.total
            
            if perPage == nil {
                Worldbank.getCapitals(perPage: total, then: handler)
            } else {
                
                guard let resultsData = try? JSONSerialization.data(withJSONObject: decoded[1], options: []),
                    let results = try? JSONDecoder().decode([WorldbankCountry].self, from: resultsData),
                    results.count == total else { return }
                
                DispatchQueue.main.async { handler(results) }
            }
            
            
            
        }.resume()
        
    }
}
