//
//  TableScreenVC.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SafariServices

class TableScreenVC: UITableViewController {

    var navigationManager: NavigationManager?
    
    var screen: Screen
    
    init(screen: Screen) {
        self.screen = screen
        super.init(style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = screen.title
        
        if let button = screen.rightButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: button.title, style: .plain, target: self, action: #selector(rightBarButtonTapped(_:)))
        }
    }
    
    
    @objc private func rightBarButtonTapped(_ sender: UIBarButtonItem) {
        guard let button = screen.rightButton else { return }
        navigationManager?.execute(button.action, from: self, view: sender.value(forKey: "view") as? UIView)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screen.rows.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = screen.rows[indexPath.row]
        
        cell.textLabel?.text = row.title
        cell.selectionStyle = row.action == nil ? .none : .default
        cell.accessoryType = row.action?.presentsNewScreen == true ? .disclosureIndicator : .none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = screen.rows[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        navigationManager?.execute(row.action, from: self, view: cell)
    }

}
