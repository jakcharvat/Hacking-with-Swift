//
//  MapDelegate.swift
//  CapitalCities
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import MapKit

class MapManager: NSObject, MKMapViewDelegate {
    weak var mapView: MKMapView!
    
    func addPin(at location: CLLocationCoordinate2D) {
        let pin = Pin(title: "Your guess", coordinate: location, color: .systemRed)
        mapView.addAnnotation(pin)
    }
}
