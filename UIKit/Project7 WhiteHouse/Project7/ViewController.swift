//
//  ViewController.swift
//  Project7
//
//  Created by Jakub Charvat on 28/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    private var petitions: [Petition] = []
    private var filteredPetitions: [Petition] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavbar()
        getPetitions()
    }
    
    
    private func getPetitions() {
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = URL(string: urlString) else {
                self.showError(title: "Invalid URL", message: "The provided URL isn't valid. ")
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                self.showError(title: "Error Fetching", message: "There was an error fetching the feed. Check your connection and try again")
                return
            }
            guard let parsed = self.parse(Petitions.self, from: data) else {
                self.showError(title: "Error Parsing", message: "There was an error parsing the feed. ")
                return
            }
            
            self.petitions = parsed.results
            self.applyPetitionFilter()
        }
    }
    
    private func parse<T: Decodable>(_ type: T.Type, from json: Data) -> T? {
        let decoder = JSONDecoder()
        
        do {
            let decoded = try decoder.decode(T.self, from: json)
            return decoded
        } catch {
            print(error)
            return nil
        }
    }
    
    private func showError(title: String, message: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
            self.present(ac, animated: true)
        }
    }
    
    @objc private func applyPetitionFilter(_ text: String? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let text = text {
                self.filteredPetitions = self.petitions.filter { $0.title.lowercased().contains(text.lowercased()) }
            } else {
                self.filteredPetitions = self.petitions
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}


//MARK: - Navbar
extension ViewController {
    private func configureNavbar() {
        title = navigationController?.tabBarItem.tag == 0 ? "Most Recent" : "Top Rated"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain,
                                                            target: self, action: #selector(showCredits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                           target: self, action: #selector(showFilterAlert))
    }
    
    @objc private func showCredits() {
        let ac = UIAlertController(title: "Data Source", message: "The data shown in this app comes from the \"We The People\" API of the White House. ", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
    }
    
    @objc private func showFilterAlert() {
        let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let clearAction = UIAlertAction(title: "Clear Filter", style: .destructive) { [weak self] _ in
            self?.applyPetitionFilter()
        }
        let applyAction = UIAlertAction(title: "Apply", style: .default) { [weak self, weak ac] _ in
            guard let filter = ac?.textFields?.first?.text else { return }
            self?.applyPetitionFilter(filter)
        }
        
        ac.addAction(clearAction)
        ac.addAction(applyAction)
        
        present(ac, animated: true)
    }
}


//MARK: - Table View
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
