//
//  WorldbankCountry.swift
//  CapitalCities
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import CoreLocation

struct WorldbankCountry: Codable {
    let capitalCity: String
    let latitude: String
    let longitude: String
    
    var capitalCoordinate: CLLocationCoordinate2D? {
        guard let lat = Double(latitude), let lon = Double(longitude) else { return nil }
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct WorldbankMeta: Codable {
    let total: Int
}
