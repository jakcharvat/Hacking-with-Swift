//
//  ViewController.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navManager = NavigationManager()
        navManager.fetch { initialScreen in
            let vc = TableScreenVC(screen: initialScreen)
            vc.navigationManager = navManager
            navigationController?.viewControllers = [ vc ]
        }
    }
}

