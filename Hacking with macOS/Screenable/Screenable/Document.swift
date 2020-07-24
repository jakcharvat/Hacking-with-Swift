//
//  Document.swift
//  Screenable
//
//  Created by Jakub Charvat on 04/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    var screenshot = Screenshot()

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        return try NSKeyedArchiver.archivedData(withRootObject: screenshot, requiringSecureCoding: false)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        if let savedScreenshot = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Screenshot {
            screenshot = savedScreenshot
        } else {
            throw ScreenshotError.BadData
        }
    }


}

enum ScreenshotError: Error {
    case BadData
}
