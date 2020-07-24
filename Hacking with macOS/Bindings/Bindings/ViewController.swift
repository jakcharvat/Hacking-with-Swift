//
//  ViewController.swift
//  Bindings
//
//  Created by Jakub Charvat on 17/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @objc dynamic var temperatureCelsius: Double = 50 {
        didSet { updateFahrenheit() }
    }
    @objc dynamic var temperatureFahrenheit: Double = 50
    
    @objc dynamic var icon: String {
        switch temperatureCelsius {
        case let temp where temp < 0:
            return "⛄️"
        case 0...10:
            return "❄️"
        case 10...20:
            return "☁️"
        case 20...30:
            return "⛅️"
        case 30...40:
            return "☀️"
        case 40...50:
            return "🔥"
        default:
            return "💀"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateFahrenheit()
    }

    override func setNilValueForKey(_ key: String) {
        if key == "temperatureCelsius" {
            temperatureCelsius = 0
        }
    }

    @IBAction func reset(_ sender: NSButton) {
        temperatureCelsius = 50
    }
    
    
    func updateFahrenheit() {
        let celsius = Measurement(value: temperatureCelsius, unit: UnitTemperature.celsius)
        temperatureFahrenheit = round(celsius.converted(to: .fahrenheit).value)
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "icon" {
            return ["temperatureCelsius"]
        }
        
        return []
    }
}

