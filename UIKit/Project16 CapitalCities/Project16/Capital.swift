//
//  Capital.swift
//  Project16
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import MapKit

class Capital: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let info: String?
    
    init(_ title: String, at coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
    
    init?(from country: WorldbankCountry) {
        guard let lat = Double(country.latitude), let lon = Double(country.longitude) else {
            return nil
        }
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.title = country.capitalCity
        self.info = nil
        
    }
    
}
