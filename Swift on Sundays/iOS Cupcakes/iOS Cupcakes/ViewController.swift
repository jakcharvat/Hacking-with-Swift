//
//  ViewController.swift
//  iOS Cupcakes
//
//  Created by Jakub Charvat on 29/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var cupcakes = [Cupcake]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
    }
    
    
    private func fetchData() {
        let url = URL(string: "http://localhost:8080/cupcakes")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "Unknown Error")
                return
            }
            
            let decoder = JSONDecoder()
            
            if let cupcakes = try? decoder.decode([Cupcake].self, from: data) {
                DispatchQueue.main.async {
                    self.cupcakes = cupcakes
                    self.tableView.reloadData()
                    print("Loaded \(cupcakes.count) cupcakes")
                }
            } else {
                print("Unable to parse JSON response")
            }
        }.resume()
    }
}



//MARK: - TableView
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cupcakes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cake = cupcakes[indexPath.row]
        
        cell.textLabel?.text = "\(cake.name) - $\(cake.price)"
        cell.detailTextLabel?.text = cake.description
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cake = cupcakes[indexPath.row]
        let ac = UIAlertController(title: "Order \(cake.name)?", message: "Please enter your name", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Order", style: .default) { _ in
            guard let name = ac.textFields?.first?.text else { return }
            self.order(cake, for: name)
        })
        present(ac, animated: true)
    }
    
    
    private func order(_ cake: Cupcake, for name: String) {
        let order = Order(cakeName: cake.name, buyerName: name)
        let url = URL(string: "http://localhost:8080/order")!
        
        let encoder = JSONEncoder()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? encoder.encode(order)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                
                if let item = try? decoder.decode(Order.self, from: data) {
                    print(item.buyerName)
                } else {
                    print("Bad JSON")
                }
            } else {
                print("No response")
            }
        }.resume()
    }
}
