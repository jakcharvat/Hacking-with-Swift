//
//  ViewController.swift
//  Project22
//
//  Created by Jakub Charvat on 11/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var circle: UIView!
    
    var locationManager: CLLocationManager?
    var shouldShowAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        circle.layer.cornerRadius = 128
        circle.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        view.backgroundColor = .gray
    }


    func startScanning() {
        let uuid = UUID(uuidString: "03C20E0D-F7D6-421B-9DD6-E35AA7742FFF")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }
}


//MARK: - Location Delegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            
            if shouldShowAlert {
                let ac = UIAlertController(title: "Beacon Found", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cool", style: .default))
                present(ac, animated: true)
                shouldShowAlert = false
            }
            
            update(with: beacon.proximity)
        } else {
            print("Not found")
            update(with: .unknown)
        }
    }
    
    func update(with distance: CLProximity) {
        
        let color: UIColor
        let scale: CGFloat
        
        switch distance {
        case .far:
            color = UIColor.blue
            scale = 0.25
            self.distanceReading.text = "FAR"

        case .near:
            color = UIColor.orange
            scale = 0.5
            self.distanceReading.text = "NEAR"

        case .immediate:
            color = UIColor.red
            scale = 1
            self.distanceReading.text = "RIGHT HERE"
            
        default:
            color = UIColor.gray
            scale = 0.001
            self.distanceReading.text = "UNKNOWN"
        }
        
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 7, options: [], animations: {
            self.circle.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.view.backgroundColor = color
        })
    }
}
