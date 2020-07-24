//
//  MapDelegate.swift
//  CapitalCities
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import MapKit

class MapManager: NSObject {
    let mapView: MKMapView
    weak var viewController: ViewController?

    init(for mapView: MKMapView) {
        self.mapView = mapView
        super.init()
        
        mapView.delegate = self
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked(recognizer:)))
        mapView.addGestureRecognizer(recognizer)
    }
    
    @objc func mapClicked(recognizer: NSClickGestureRecognizer) {
        if mapView.annotations.count == 0 {
            addPin(at: mapView.convert(recognizer.location(in: mapView), toCoordinateFrom: mapView))
        } else {
            mapView.removeAnnotations(mapView.annotations)
            viewController?.nextCity()
        }
    }
    
    func addPin(at location: CLLocationCoordinate2D) {
        guard let city = viewController?.currentCity else { return }
        
        let pin = Pin(title: "Your guess", coordinate: location, color: .systemRed)
        mapView.addAnnotation(pin)
        mapView.addAnnotation(city)
        
        let point1 = MKMapPoint(city.coordinate)
        let point2 = MKMapPoint(pin.coordinate)
        
        let distance = point1.distance(to: point2) / 1000 // km
        let score = Int(max(0, 500 - distance))
        viewController?.score += score
        
        city.subtitle = "Distance: \(Int(distance))km. You scored \(score)"
        mapView.selectAnnotation(city, animated: true)
    }
}


//MARK: - Map Delegate
extension MapManager: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pin = annotation as? Pin else { return nil }
        let identifier = "Guess"
        
        let annotationView: MKPinAnnotationView
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            annotationView = view
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView.canShowCallout = true
        annotationView.pinTintColor = pin.color
        
        return annotationView
    }
}
