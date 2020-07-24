//
//  SourceVC.swift
//  StormViewer
//
//  Created by Jakub Charvat on 31/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class SourceVC: NSViewController {

    @IBOutlet var tableView: NSTableView!
    
    var pictures: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl") {
                pictures.append(item)
            }
        }
    }
    
}


//MARK: - Table View DataSource
extension SourceVC: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return pictures.count
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let vw = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        let picture = pictures[row]
        
        vw.textField?.stringValue = picture
        vw.imageView?.image = NSImage(named: picture)
        
        return vw
    }
}


//MARK: - Table View Delegate
extension SourceVC: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else { return }
        guard let splitVC = parent as? NSSplitViewController else { return }
        
        if let detailVC = splitVC.children[1] as? DetailVC {
            detailVC.imageSelected(name: pictures[tableView.selectedRow])
        }
    }
}
