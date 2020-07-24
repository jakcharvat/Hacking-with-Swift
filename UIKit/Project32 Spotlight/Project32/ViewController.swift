//
//  ViewController.swift
//  Project32
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SafariServices
import CoreSpotlight
import MobileCoreServices
import SnapKit

class ViewController: UITableViewController {
    
    var projects = [Project]()
    
    var dataSource: UITableViewDiffableDataSource<Int, Project>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Project.getProjects { [weak self] (success, projects) in
            guard let self = self, success, let projects = projects else { print("Error"); return }
            
            self.projects = projects
            self.applySnapshot()
        }
        
        tableView.register(ProjectCell.self, forCellReuseIdentifier: "Cell")
        configureDataSource()
        tableView.dataSource = dataSource
    }
    
    func showTutorial(for project: Project) {
        showTutorial(at: project.url)
    }
    
    func showTutorial(at url: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let safariVC = SFSafariViewController(url: url, configuration: config)
        present(safariVC, animated: true)
    }
}
    
 
//MARK: - TableView DataSource
extension ViewController {
    
    func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, Project>(tableView: tableView, cellProvider: { (tableView, indexPath, project) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ProjectCell else { return nil }
            
            let project = self.projects[indexPath.row]
            
            let config = UIImage.SymbolConfiguration(scale: .large)
            let image: UIImage
            let tintColor: UIColor
            if project.isFavourite {
                image = UIImage(systemName: "star.fill", withConfiguration: config)!
                tintColor = .systemYellow
            } else {
                image = UIImage(systemName: "star", withConfiguration: config)!
                tintColor = .label
            }
            
            cell.favouriteButton.setImage(image, for: .normal)
            cell.favouriteButton.tag = indexPath.row
            cell.favouriteButton.tintColor = tintColor
            cell.favouriteButton.addTarget(self, action: #selector(self.toggleSelection(_:)), for: .touchUpInside)
            cell.textView.attributedText = self.makeAttributedString(for: project)
            
            return cell
        })
    }
    
    
    func applySnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Project>()
        snapshot.appendSections([0])
        snapshot.appendItems(projects)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(for: projects[indexPath.row])
    }
    
    @objc func toggleSelection(_ sender: UIButton) {
        projects[sender.tag].toggleFavourite()
        
        let project = projects[sender.tag]
        if project.isFavourite {
            index(project: project)
        } else {
            deindex(project: project)
        }
        
        Project.saveProjectsToUserDefaults(projects)
        applySnapshot(animated: false)
    }
    
    private func makeAttributedString(for project: Project) -> NSAttributedString {
        let titleAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.preferredFont(forTextStyle: .headline),
            .foregroundColor: UIColor.systemPurple
        ]
        let subtitleAttributes: [NSAttributedString.Key : Any] = [ .font: UIFont.preferredFont(forTextStyle: .subheadline) ]
        
        let titleString = NSMutableAttributedString(string: "\(project.title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: project.subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        return titleString
    }
}


//MARK: - Spotlight
extension ViewController {
    func index(project: Project) {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project.title
        attributeSet.contentDescription = project.subtitle
        
        let url = project.url.absoluteString
        
        let item = CSSearchableItem(uniqueIdentifier: url, domainIdentifier: "dev.jakcharvat", attributeSet: attributeSet)
        item.expirationDate = .distantFuture
        CSSearchableIndex.default().indexSearchableItems([ item ]) { error in
            if let error = error {
                print("Indexing Error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindex(project: Project) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [ project.url.absoluteString ]) { error in
            if let error = error {
                print("Deletion Error: \(error.localizedDescription)")
            } else {
                print("Search item successfully deleted!")
            }
        }
    }
}
