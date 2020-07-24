//
//  FriendViewController.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit


class FriendVC: UITableViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    var friend: Friend!
    var timezones: [TimeZone] = [ ]
    var selectedTimeZone = 0
    
    var nameEditingCell: TextTableViewCell? {
        let indexPath = IndexPath(row: 0, section: 0)
        return tableView.cellForRow(at: indexPath) as? TextTableViewCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavbar()
        getTimeZones()
    }
    
    func configureNavbar() {
        title = friend.name
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func getTimeZones() {
        let identifiers = TimeZone.knownTimeZoneIdentifiers
        
        for identifier in identifiers {
            if let timezone = TimeZone(identifier: identifier) {
                timezones.append(timezone)
            }
        }
        
        timezones.sort { a, b in
            let aFromGMT = a.secondsFromGMT()
            let bFromGMT = b.secondsFromGMT()
            
            if aFromGMT == bFromGMT {
                return a.identifier < b.identifier
            }
            
            return aFromGMT < bFromGMT
        }
        
        selectedTimeZone = timezones.firstIndex(of: friend.timezone) ?? 0
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        friend.name = sender.text ?? ""
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.updateFriend(friend)
    }
}


//MARK: - Table View Datasource
extension FriendVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return timezones.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Name your friend"
        }
        
        return "Select their timezone"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath) as? TextTableViewCell else {
                fatalError("Unable to dequeue TextTableViewCell")
            }
            
            cell.textField.text = friend.name
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimezoneCell", for: indexPath)
        let timezone = timezones[indexPath.row]
        
        cell.textLabel?.text = timezone.formattedIdentifier
        cell.detailTextLabel?.text = timezone.secondsFromGMT().timeString()
        cell.accessoryType = indexPath.row == selectedTimeZone ? .checkmark : .none
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            startEditingName()
            return
        }
        
        selectRow(at: indexPath)
    }
    
    
    func selectRow(at indexPath: IndexPath) {
        endEditingName()
        
        let currentlySelectedIndexPath = IndexPath(row: selectedTimeZone, section: 1)
        selectedTimeZone = indexPath.row
        friend.timezone = timezones[indexPath.row]
        
        tableView.cellForRow(at: currentlySelectedIndexPath)?.accessoryType = .none
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - Name Editing
extension FriendVC {
    func startEditingName() {
        nameEditingCell?.textField.becomeFirstResponder()
    }
    
    
    func endEditingName() {
        nameEditingCell?.textField.resignFirstResponder()
    }
}
