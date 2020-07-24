//
//  ViewController.swift
//  WeatherBad
//
//  Created by Jakub Charvat on 02/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa
import MapKit
import KeychainSwift

class ViewController: NSViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapViewContainer: NSView!
    @IBOutlet var apiKey: NSTextField!
    @IBOutlet var statusBarOption: NSPopUpButton!
    @IBOutlet var units: NSSegmentedControl!
    @IBOutlet var useCurrentLocation: NSButton!
    
    private let keychain = KeychainSwift()
    
    private var mapGestureRecognizer: NSGestureRecognizer?
    private var mapViewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSettings()
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapClicked(recognizer:)))
        mapView.addGestureRecognizer(recognizer)
        mapGestureRecognizer = recognizer
    }
    
    
    
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        if let recognizer = mapGestureRecognizer {
            mapView.removeGestureRecognizer(recognizer)
        }

        saveSettings()
    }
    
    
    private func loadSettings() {
        let savedUseLocation = !UserDefaults.standard.bool(forKey: "disallowedLocation")
        let savedLat = UserDefaults.standard.double(forKey: "lat")
        let savedLon = UserDefaults.standard.double(forKey: "lon")
        let savedStatusBar = UserDefaults.standard.integer(forKey: "statusBarOption")
        let savedUnits = UserDefaults.standard.integer(forKey: "units")
        let savedApiKey = keychain.get("apiKey") ?? ""
        
        useCurrentLocation.state = savedUseLocation ? .on : .off
        updateMapViewHeightConstraint(animated: false)
        
        apiKey.stringValue = savedApiKey
        units.selectedSegment = savedUnits
        
        for menuItem in statusBarOption.menu!.items {
            if menuItem.tag == savedStatusBar {
                statusBarOption.select(menuItem)
            }
        }
        
        if UserDefaults.standard.value(forKey: "lat") != nil {
            let savedLocation = CLLocationCoordinate2D(latitude: savedLat, longitude: savedLon)
            addPin(at: savedLocation)
            mapView.centerCoordinate = savedLocation
        }
    }
    
    
    private func saveSettings() {
        if let annotation = mapView.annotations.first {
            UserDefaults.standard.set(annotation.coordinate.latitude, forKey: "lat")
            UserDefaults.standard.set(annotation.coordinate.longitude, forKey: "lon")
        }
        
        UserDefaults.standard.set(useCurrentLocation.state == .off, forKey: "disallowedLocation")
        UserDefaults.standard.set(units.selectedSegment, forKey: "units")
        UserDefaults.standard.set(statusBarOption.selectedTag(), forKey: "statusBarOption")
        keychain.set(apiKey.stringValue, forKey: "apiKey")
        
        NotificationCenter.default.post(name: .init("SettingsChanged"), object: nil)
    }
    
    
    @objc private func mapClicked(recognizer: NSClickGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        let clickLocation = recognizer.location(in: mapView)
        let location = mapView.convert(clickLocation, toCoordinateFrom: mapView)
        addPin(at: location)
    }
    
    
    private func addPin(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Your location"
        mapView.addAnnotation(annotation)
    }
    
    
    private func updateMapViewHeightConstraint(animated: Bool) {
        if mapViewHeightConstraint == nil {
            mapViewHeightConstraint = mapViewContainer.heightAnchor.constraint(equalToConstant: 0)
            mapViewHeightConstraint?.isActive = true
        }
        
        let height: CGFloat = useCurrentLocation.state == .on ? 0 : 350
        let alpha: CGFloat = useCurrentLocation.state == .on ? 0 : 1
        mapViewHeightConstraint?.constant = height
        
        mapViewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        if animated {
            NSAnimationContext.current.duration = 1
            NSAnimationContext.current.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            NSAnimationContext.current.allowsImplicitAnimation = true
            mapViewContainer.animator().layoutSubtreeIfNeeded()
            mapViewContainer.animator().alphaValue = alpha
        } else {
            mapViewContainer.layoutSubtreeIfNeeded()
        }
    }

    
    @IBAction func useCurrentLocationClicked(_ sender: NSButton) {
        updateMapViewHeightConstraint(animated: true)
    }
    
    
    @IBAction func poweredByClicked(_ sender: NSButton) {
        if let url = URL(string: "https://openweathermap.org") {
            NSWorkspace.shared.open(url)
        }
    }
}

