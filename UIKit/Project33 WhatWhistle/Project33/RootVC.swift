//
//  ViewController.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class RootVC: UITableViewController {
    
    let whistleManager = WhistleManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        whistleManager.delegate = self
        
        configureNavbar()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        whistleManager.loadWhistles()
    }
}


//MARK: - UI Config
extension RootVC {
    private func configureNavbar() {
        title = "What's that Whistle?"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left.to.line.alt"), style: .plain, target: self, action: #selector(signOut(_:)))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
    }
}


//MARK: - Signing Out
extension RootVC {
    @objc private func signOut(_ sender: UIBarButtonItem) {
        Firebase.shared.signout()
        navigationController?.viewControllers.insert(AuthVC(), at: 0)
        navigationController?.popToRootViewController(animated: true)
    }
}


//MARK: - Whistles
extension RootVC {
    @objc private func addWhistle(_ sender: UIBarButtonItem) {
        let vc = RecordWhistleVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}


//MARK: - Whistle Manager
extension RootVC: WhistleManagerDelegate {
    func whistleManager(_ whistleManager: WhistleManager, didLoadWhistles: [Whistle]) {
        tableView.reloadData()
    }
    
    func whistleManagerDidFailFetchingWhistles(_ whistleManager: WhistleManager) {
        print("didFail")
    }
}


//MARK: - Data Source
extension RootVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return whistleManager.whistles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let c = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = c
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        let whistle = whistleManager.whistles[indexPath.row]
        
        cell.textLabel?.text = whistle.genre.rawValue
        cell.detailTextLabel?.text = whistle.comments
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let whistle = whistleManager.whistles[indexPath.row]
        print(whistle.comments)
        
        let fm = FileManager()
        let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(try? fm.contentsOfDirectory(atPath: url.path))
        print(whistle.id)
    }
}
