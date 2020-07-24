//
//  LoadScriptViewController.swift
//  Extension
//
//  Created by Jakub Charvat on 11/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class LoadScriptViewController: UITableViewController {
    
    private var scripts: [String : String]!
    private var scriptNames: [String]!
    
    weak var delegate: LoadScriptDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scripts = UserDefaults.standard.dictionary(forKey: "savedScripts") as? [String : String] ?? [:]
        scriptNames = Array(scripts.keys).sorted()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        title = "Choose Script"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = scriptNames[indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scriptName = scriptNames[indexPath.row]
        let script = scripts[scriptName]!
        
        let vc = ScriptDetailViewController()
        vc.scriptName = scriptName
        vc.script = script
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let scriptToDelete = scriptNames.remove(at: indexPath.row)
            scripts.removeValue(forKey: scriptToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            DispatchQueue.global(qos: .background).async {
                UserDefaults.standard.set(self.scripts, forKey: "savedScripts")
            }
        }
    }
}


//MARK: - Script Detail Delegate
extension LoadScriptViewController: ScriptDetailDelegate {
    func scriptDetailDidPressLoad(_ scriptDetail: ScriptDetailViewController) {
        guard let script = scriptDetail.script else { return }
        delegate?.loadScript(self, choseToLoad: script)
        dismiss(animated: true)
    }
}


//MARK: - Delegate
protocol LoadScriptDelegate: class {
    func loadScript(_ loadScript: LoadScriptViewController, choseToLoad script: String)
}
