//
//  NavigationManager.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SafariServices
import AVKit

class NavigationManager {
    private var screens: [String : Screen] = [:]
    
    func fetch(then completion: (Screen) -> ()) {
        let url = URL(string: "http://localhost:8080/index.json")!
        let data = try! Data(contentsOf: url)
        let app = try! JSONDecoder().decode(Application.self, from: data)
        
        for screen in app.screens {
            screens[screen.id] = screen
        }
        
        completion(app.screens.first!)
    }
    
    
    func execute(_ action: Action?, from viewController: UIViewController, view: UIView?) {
        guard let action = action else { return }
        
        if let action = action as? AlertAction {
            let ac = UIAlertController(title: action.title, message: action.message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            viewController.present(ac, animated: true)
        }
        
        else if let action = action as? ShowWebsiteAction {
            let vc = SFSafariViewController(url: action.url)
            viewController.present(vc, animated: true)
        }
        
        else if let action = action as? ShowScreenAction {
            guard let screen = screens[action.id] else {
                fatalError("Attempting to show unknown screen: \(action.id)")
            }
            
            let vc = TableScreenVC(screen: screen)
            vc.navigationManager = self
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        
        else if let action = action as? PlayMovieAction {
            let player = AVPlayer(url: action.url)
            let vc = AVPlayerViewController()
            vc.player = player
            player.play()
            
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
        
        else if let action = action as? ShareAction {
            var items: [Any] = [ ]
            
            if let text = action.text { items.append(text) }
            if let url = action.url { items.append(url) }
            
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = view
            viewController.present(ac, animated: true)
        }
    }
}
