//
//  ViewController.swift
//  Project1
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures: [String] = []
    var viewCounter: ViewCounter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCounter = ViewCounter()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getPictures()
        }
    }
    
    
    private func getPictures() {
        let fm = FileManager()
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        pictures = items.filter { $0.hasPrefix("nssl") }.sorted()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    @objc private func share() {
        let vc = UIActivityViewController(activityItems: ["Storm Viewer"], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}


//MARK: - Table View Controller
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture
        cell.detailTextLabel?.text = "Views: \(viewCounter.views(for: picture))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController else { return }
        
        detailVC.imageName = pictures[indexPath.row]
        detailVC.imageIndex = indexPath.row + 1
        detailVC.imageCount = pictures.count
        
        viewCounter.view(image: pictures[indexPath.row])
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

