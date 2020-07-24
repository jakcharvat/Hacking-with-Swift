//
//  OpenWeatherMapResponse.swift
//  WeatherBad
//
//  Created by Jakub Charvat on 03/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct OpenWeatherMapResponse: Decodable {
    private let current: Current
    private let hourly: [Hourly]
    
    var units = "°C"
    private var update = Date()
    
    enum CodingKeys: CodingKey {
        case current, hourly
    }
    
    var summary: String? {
        current.weather.first?.description.capitalized
    }
    
    var temperature: String {
        "\(Int(current.temp))\(units)"
    }
    
    var precipitation: String {
        "\(String(format: "%g", current.rain?.lastHour ?? 0))mm"
    }
    
    var cloudCover: String {
        "\(Int(current.clouds))%"
    }
    
    var hours: [Hourly.Hour] {
        hourly[..<12].map { Hourly.Hour(from: $0, units: units) }
    }
    
    var updateTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: update)
    }
    
    
    struct Current: Decodable {
        let weather: [Weather]
        let temp: Double
        let rain: Rain?
        let clouds: Double
        
        struct Rain: Decodable {
            let lastHour: Double?
            
            enum CodingKeys: String, CodingKey {
                case lastHour = "1h"
            }
        }
    }
    
    struct Hourly: Decodable {
        let dt: TimeInterval
        let weather: [Weather]
        let temp: Double
        
        struct Hour: Decodable {
            init(from hourly: Hourly, units: String) {
                let date = Date(timeIntervalSince1970: hourly.dt)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                time = formatter.string(from: date)
                
                description = hourly.weather.first?.description.capitalized ?? ""
                
                temperature = "\(Int(hourly.temp))\(units)"
            }
            
            let time: String
            let description: String
            let temperature: String
        }
    }
    
    struct Weather: Decodable {
        let description: String
    }
}
