//
//  ViewController.swift
//  Project21
//
//  Created by Jakub Charvat on 11/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
        NotificationCenter.default.addObserver(self, selector: #selector(foregrounded), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        foregrounded()
    }
    
    @objc func foregrounded() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let response = delegate.response else { return }
        delegate.response = nil
        
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            let title: String
            let message: String
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                title = "Default Action"
                message = "You just opened the notification the normal way"
                
            case "show":
                title = "Show more..."
                message = "You clicked the show more button"
            case "later":
                scheduleLocal()
                return
                
            default:
                return
            }
            
            print(title, message)
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            
            DispatchQueue.main.async {
                self.present(ac, animated: true)
            }
        }
    }
    
    @objc func scheduleLocal() {
        registerCategories()
        
        let centre = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        centre.add(request)
        
    }
    
    func registerCategories() {
        let centre = UNUserNotificationCenter.current()
        
        let showAction = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let showLaterAction = UNNotificationAction(identifier: "later", title: "Show later", options: .authenticationRequired)
        let category = UNNotificationCategory(identifier: "alarm", actions: [showAction, showLaterAction], intentIdentifiers: [])
        
        centre.setNotificationCategories([category])
    }
}
