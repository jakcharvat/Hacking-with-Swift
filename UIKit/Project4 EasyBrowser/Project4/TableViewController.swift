//
//  TableViewController.swift
//  Project4
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    let websites = ["hackingwithswift.com", "apple.com", "google.com"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Easy Browser"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let webVC = storyboard?.instantiateViewController(identifier: "Web") as? WebViewController else { return }
        
        webVC.website = websites[indexPath.row]
        navigationController?.pushViewController(webVC, animated: true)
    }
}
