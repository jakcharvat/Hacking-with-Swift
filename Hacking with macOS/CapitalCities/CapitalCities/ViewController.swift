//
//  ViewController.swift
//  CapitalCities
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController {
    
    @IBOutlet private var questionLabel: NSTextField!
    @IBOutlet private var scoreLabel: NSTextField!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var blurView: NSVisualEffectView!
    @IBOutlet private var spinner: NSProgressIndicator!
    
    var mapManager: MapManager!
    
    var cities = [Pin]()
    var allCities = [Pin]()
    var currentCity: Pin?
    var score = 0 {
        didSet {
            scoreLabel.stringValue = "Score: \(score)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.startAnimation(self)
        
        mapManager = MapManager(for: mapView)
        mapManager.viewController = self
        
        getCities()
    }
    
    
    func getCities() {
        Worldbank.getCapitals { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let capitals):
                    self.createCities(from: capitals)
                    self.blurView.isHidden = true
                    self.mapView.isScrollEnabled = true
                    self.mapView.isZoomEnabled = true
                
                case .failure(let error):
                    let alert = NSAlert()
                    alert.messageText = "Error fetching capitals"
                    alert.informativeText = error.localizedDescription
                    alert.beginSheetModal(for: self.view.window!) { _ in
                        self.getCities()
                    }
                }
            }
        }
    }
    
    
    func createCities(from countries: [WorldbankCountry]) {
        allCities = countries.compactMap { country in
            guard let coordinate = country.capitalCoordinate else { return nil }
            guard !country.capitalCity.replacingOccurrences(of: " ", with: "").isEmpty else { return nil }
            print(country.capitalCity)
            return Pin(title: country.capitalCity, coordinate: coordinate)
        }
        
        startNewGame()
    }
    
    
    func startNewGame() {
        score = 0
        
        allCities.shuffle()
        cities = Array(allCities[..<5])
        
        nextCity()
    }
    
    func nextCity() {
        if let city = cities.popLast() {
            currentCity = city
            questionLabel.stringValue = "Where is \(city.title!)?"
        } else {
            currentCity = nil
            let alert = NSAlert()
            alert.messageText = "Final score: \(score)"
            alert.beginSheetModal(for: view.window!) { [weak self] _ in
                self?.startNewGame()
            }
        }
    }
}

