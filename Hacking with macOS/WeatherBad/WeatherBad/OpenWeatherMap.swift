//
//  OpenWeatherMap.swift
//  WeatherBad
//
//  Created by Jakub Charvat on 02/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation
import KeychainSwift
import CoreLocation


class OpenWeatherMap: NSObject {
    
    private var callback: (Result<OpenWeatherMapResponse, Error>) -> Void = { _ in }
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    func fetch(then completion: @escaping (Result<OpenWeatherMapResponse, Error>) -> Void) {
        let shouldUseCurrentLocation = !UserDefaults.standard.bool(forKey: "disallowedLocation")
        
        if shouldUseCurrentLocation {
            callback = completion
            locationManager.startUpdatingLocation()
        } else {
            guard UserDefaults.standard.object(forKey: "lat") != nil else {
                completion(.failure(OpenWeatherMapError.noLocation))
                return
            }
            
            let lat = UserDefaults.standard.double(forKey: "lat")
            let lon = UserDefaults.standard.double(forKey: "lon")
            
            sendRequest(lat: lat, lon: lon, then: completion)
        }
    }
    
    
    private func sendRequest(lat: Double, lon: Double, then completion: @escaping (Result<OpenWeatherMapResponse, Error>) -> Void) {
        guard let apiKey = KeychainSwift().get("apiKey"), !apiKey.isEmpty else {
            completion(.failure(OpenWeatherMapError.noApiKey))
            return
        }
        
        let units = UserDefaults.standard.integer(forKey: "units")
        let unitsString: String
        
        switch units {
        case 1:
            unitsString = ""
        case 2:
            unitsString = "&units=imperial"
        default:
            unitsString = "&units=metric"
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(apiKey)\(unitsString)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(OpenWeatherMapError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let response = response as? HTTPURLResponse {
                guard response.statusCode == 200 else {
                    completion(.failure(OpenWeatherMapError.non200StatusCode))
                    return
                }
            }
            
            guard let data = data, error == nil else {
                completion(.failure(error ?? OpenWeatherMapError.noData))
                return
            }
            
            do {
                var weather = try JSONDecoder().decode(OpenWeatherMapResponse.self, from: data)
                
                if units == 1 {
                    weather.units = "K"
                } else if units == 2 {
                    weather.units = "°F"
                }
                
                completion(.success(weather))
                self.callback = { _ in }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


//MARK: - Location
extension OpenWeatherMap: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.authorized {
            callback(.failure(OpenWeatherMapError.notAuthorized))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        print("Update")
        
        if let location = locations.first {
            let coord = location.coordinate
            sendRequest(lat: coord.latitude, lon: coord.longitude, then: callback)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        callback(.failure(OpenWeatherMapError.locationDidFail))
        print(error)
    }
}


//MARK: - Errors
enum OpenWeatherMapError: String, Error {
    case noApiKey = "No API Key"
    case noLocation = "No Location"
    case invalidURL = "Invalid URL"
    case non200StatusCode = "Response Error"
    case noData = "No Data"
    case notAuthorized = "Location Denied"
    case locationDidFail = "Location Error"
}
