//
//  Document.swift
//  JustType
//
//  Created by Jakub Charvat on 29/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    var text = ""
    
    override func contents(forType typeName: String) throws -> Any {
        return Data(text.utf8)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { throw DocumentError.InvalidData }
        guard let text = String(data: data, encoding: .utf8) else { throw DocumentError.InvalidData }
        self.text = text
    }
    
    
    enum DocumentError: Error {
        case InvalidData
    }
}
