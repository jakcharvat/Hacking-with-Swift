//
//  ViewController.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class RootVC: UITableViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    var friends: [Friend] = [ ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavbar()
        loadData()
    }
    
    
    func configureNavbar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend(_:)))
    }
    
    
    @objc func addFriend(_ sender: UIBarButtonItem) {
        let friend = Friend()
        friends.append(friend)
        
        let indexPath = IndexPath(row: friends.count - 1, section: 0)
        tableView.insertRows(at: [ indexPath ], with: .automatic)
        
        saveData()
        coordinator?.showFriend(friend, from: indexPath.row)
    }
}


//MARK: - Table View DataSource
extension RootVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = friend.timezone
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = friend.name
        cell.detailTextLabel?.text = dateFormatter.string(from: Date())
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showFriend(friends[indexPath.row], from: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        friends.remove(at: indexPath.row)
        tableView.deleteRows(at: [ indexPath ], with: .automatic)
    }
}


//MARK: - Update Friend
extension RootVC {
    func updateFriend(_ newFriend: Friend, at index: Int) {
        friends[index] = newFriend
        tableView.reloadData()
        saveData()
    }
}


//MARK: - Data persistance
extension RootVC {
    func loadData() {
        guard let data = UserDefaults.standard.data(forKey: "Friends") else { return }
        guard let friends = try? JSONDecoder().decode([Friend].self, from: data) else { return }
        
        self.friends = friends
    }
    
    
    func saveData() {
        guard let data = try? JSONEncoder().encode(friends) else { return }
        UserDefaults.standard.set(data, forKey: "Friends")
    }
}
