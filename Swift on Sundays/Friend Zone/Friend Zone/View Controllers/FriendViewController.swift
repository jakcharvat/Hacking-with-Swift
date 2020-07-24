//
//  FriendViewController.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit


class FriendVC: UITableViewController {
    weak var delegate: RootVC?
    var friend: Friend!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
