//
//  Project.swift
//  Project32
//
//  Created by Jakub Charvat on 14/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation

struct Project: Codable, Hashable {
    let title: String
    let subtitle: String
    let url: URL
    var isFavourite: Bool = false
    
    mutating func toggleFavourite() {
        isFavourite.toggle()
    }
}


//MARK: - Fetching Projects
extension Project {
    static func getProjects(then callback: @escaping (Bool, [Project]?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let projects = loadProjectsFromUserDefaults() {
                DispatchQueue.main.async { callback(true, projects) }
                return
            }
            
            fetchProjects(then: callback)
        }
    }
    
    private static func loadProjectsFromUserDefaults() -> [Project]? {
        guard let data = UserDefaults.standard.data(forKey: "projects"),
            let projects = try? JSONDecoder().decode([Project].self, from: data) else { return nil }
        
        return projects
    }
    
    private static func fetchProjects(then callback: @escaping (Bool, [Project]?) -> ()) {
        guard let listUrl = URL(string: "https://www.hackingwithswift.com/read") else { return }
        guard let htmlString = try? String(contentsOf: listUrl) else { return }
        
        let htmlLines = htmlString.components(separatedBy: .newlines)
        let titleNodes = htmlLines.filter { $0.contains("<h2 class=\"title\"") }
        let titles = titleNodes.filter({ $0.contains("Project") }).map { (node) -> String in
            var h2split = node.components(separatedBy: "<h2")
            h2split.remove(at: 0)
            let titleStrippedStart = h2split.joined().components(separatedBy: ">")[1]
            let title = titleStrippedStart.components(separatedBy: "<")[0]
            return title
        }
        let subtitleNodes = htmlLines.filter { $0.hasPrefix("<h4 class=\"mt-0\">") }
        let subtitles = subtitleNodes.map { (node) -> String in
            let startSplit = node.components(separatedBy: ">")
            let start = startSplit[1]
            let endSplit = start.components(separatedBy: "<")
            return endSplit[0]
        }
        
        if titles.isEmpty || titles.count != subtitles.count {
            DispatchQueue.main.async { callback(false, nil) }
            return
        }
        
        let projects = titles.enumerated().compactMap { (titleEnum) -> Project? in
            let title = titleEnum.element
            let subtitle = subtitles[titleEnum.offset]
            guard let url = URL(string: "https://www.hackingwithswift.com/read/\(titleEnum.offset + 1)") else { return nil }
            
            return Project(title: title, subtitle: subtitle, url: url)
            
        }
        
        saveProjectsToUserDefaults(projects)
        
        DispatchQueue.main.async { callback(true, projects) }
    }
    
    static func saveProjectsToUserDefaults(_ projects: [Project]) {
        guard let encoded = try? JSONEncoder().encode(projects) else { return }
        UserDefaults.standard.set(encoded, forKey: "projects")
    }
}
