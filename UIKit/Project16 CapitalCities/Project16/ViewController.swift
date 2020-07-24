//
//  ViewController.swift
//  Project16
//
//  Created by Jakub Charvat on 01/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet private var mapView: MKMapView!
    private var typePicker: MapTypePicker!
    
    private let mapTypes: [String] = ["Standard", "Hybrid", "Satellite"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAnnotations()
        configureTypePicker()
        
        getCapitals()
    }
    
    private func configureTypePicker() {
        typePicker = MapTypePicker(types: mapTypes)
        typePicker.translatesAutoresizingMaskIntoConstraints = false
        typePicker.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
        view.addSubview(typePicker)
        
        NSLayoutConstraint.activate([
            typePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            typePicker.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -34)
        ])
    }
    
    private func configureAnnotations() {
        let london = Capital("London", at: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital("Oslo", at: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital("Paris", at: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital("Rome", at: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital("Washington DC", at: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }


}


//MARK: - Map View Delegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            annotationView.annotation = annotation
            return annotationView
        }
        
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView.canShowCallout = true
        
        let button = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        guard let name = capital.title else { return }
        
        let webVC = WebViewController()
        webVC.cityName = name
        navigationController?.pushViewController(webVC, animated: true)
    }
}


//MARK: - Map Type Switching
extension ViewController {
    @objc private func mapTypeChanged(_ sender: MapTypePicker) {
        let index = typePicker.selectedItemIndex
        let type = mapTypes[index]
        let mapType: MKMapType
        
        switch type {
        case "Standard":
            mapType = .standard
        case "Hybrid":
            mapType = .hybrid
        case "Satellite":
            mapType = .satellite
        default:
            return
        }
        
        mapView.mapType = mapType
        
    }
}


//MARK: - Capitals
extension ViewController {
    private func getCapitals() {
        DispatchQueue.global(qos: .userInitiated).async {
            Worldbank.getCapitals { [weak self] results in
                self?.setCapitals(from: results)
            }
        }
    }
    
    private func setCapitals(from countries: [WorldbankCountry]) {
        let capitals = countries.compactMap(Capital.init(from:))
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(capitals)
    }
}
