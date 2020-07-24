//
//  Worldbank.swift
//  CapitalCities
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Worldbank {
    
    static private let baseURL = "https://api.worldbank.org/v2/country"
    
    static func getCapitals(perPage: Int? = nil, then handler: @escaping (Result<[WorldbankCountry], Error>) -> Void) {
        
        let urlString = "\(baseURL)?format=json&per_page=\(perPage ?? 1)"
        guard let url = URL(string: urlString) else {
            handler(.failure(WorldbankError.unableToCreateURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data, error == nil else {
                handler(.failure(error ?? WorldbankError.noData))
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
                    results.count == total else {
                        handler(.failure(WorldbankError.badData))
                        return
                }
                
                DispatchQueue.main.async { handler(.success(results)) }
            }
            
        }.resume()
        
    }
    
    
    enum WorldbankError: String, LocalizedError {
        case noData = "The server didn't provide any data"
        case unableToCreateURL = "Couldn't create a valid URL"
        case badData = "The server returned either corrupted or incomplete data"
        
        var localizedDescription: String { rawValue }
    }
}
