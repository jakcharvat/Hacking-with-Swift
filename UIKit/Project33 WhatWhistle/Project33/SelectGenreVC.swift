//
//  SelectGenreVC.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class SelectGenreVC: UITableViewController {
    
    static let genres = Genre.allCases
    var uuidString: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavbar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func configureNavbar() {
        title = "Select genre"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreVC.genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = SelectGenreVC.genres[indexPath.row].rawValue
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genre = SelectGenreVC.genres[indexPath.row]
        let vc = AddCommentsVC()
        vc.genre = genre
        vc.uuidString = uuidString
        navigationController?.pushViewController(vc, animated: true)
    }

}
