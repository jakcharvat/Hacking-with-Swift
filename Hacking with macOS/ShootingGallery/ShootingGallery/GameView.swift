//
//  GameView.swift
//  ShootingGallery
//
//  Created by Jakub Charvat on 14/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit

class GameView: SKView {

    override func resetCursorRects() {
        if let targetImage = NSImage(named: "cursor") {
            let cursor = NSCursor(image: targetImage, hotSpot: NSPoint(x: targetImage.size.width / 2, y: targetImage.size.height / 2))
            addCursorRect(frame, cursor: cursor)
        }
    }
    
}
