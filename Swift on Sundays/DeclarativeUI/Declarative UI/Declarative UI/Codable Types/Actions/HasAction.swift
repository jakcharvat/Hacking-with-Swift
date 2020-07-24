//
//  HasAction.swift
//  Declarative UI
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Foundation


protocol HasAction { }

extension HasAction {
    func decodeAction(from container: KeyedDecodingContainer<ActionCodingKeys>) throws -> Action? {
        if let actionType = try container.decodeIfPresent(String.self, forKey: .actionType) {
            switch actionType {
            case "alert":
                return try container.decode(AlertAction.self, forKey: .action)
            case "showWebsite":
                return try container.decode(ShowWebsiteAction.self, forKey: .action)
            case "showScreen":
                return try container.decode(ShowScreenAction.self, forKey: .action)
            case "share":
                return try container.decode(ShareAction.self, forKey: .action)
            case "playMovie":
                return try container.decode(PlayMovieAction.self, forKey: .action)
            default:
                throw ActionDecodingError.UnknownActionType(actionType)
            }
        }
        
        return nil
    }
}

enum ActionDecodingError: Error {
    case UnknownActionType(_ message: String)
}
