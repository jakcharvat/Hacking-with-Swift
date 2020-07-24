//
//  Screenshot.swift
//  Screenable
//
//  Created by Jakub Charvat on 05/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class Screenshot: NSObject, NSCoding {
    var caption = "Your text here"
    var alignment = 1
    var captionFontName = " HelveticaNeue-Medium"
    var captionFontSize = 3
    var captionColor = NSColor.black
    
    var backgroundImage = ""
    var backgroundColorStart = NSColor.clear
    var backgroundColorEnd = NSColor.clear
    
    var dropShadowStrength = 1
    var dropShadowTarget = 2
    
    var screenshot: NSImage?
    
    override init() { }
    
    required init?(coder: NSCoder) {
        caption = coder.decodeObject(forKey: "caption") as! String
        alignment = coder.decodeInteger(forKey: "alignment")
        captionFontName = coder.decodeObject(forKey: "captionFontName") as! String
        captionFontSize = coder.decodeInteger(forKey: "captionFontSize")
        captionColor = coder.decodeObject(forKey: "captionColor") as! NSColor
        
        backgroundImage = coder.decodeObject(forKey: "backgroundImage") as! String
        backgroundColorStart = coder.decodeObject(forKey: "backgroundColorStart") as! NSColor
        backgroundColorEnd = coder.decodeObject(forKey: "backgroundColorEnd") as! NSColor

        dropShadowStrength = coder.decodeInteger(forKey: "dropShadowStrength")
        dropShadowTarget = coder.decodeInteger(forKey: "dropShadowTarget")
        
        screenshot = coder.decodeObject(forKey: "screenshot") as? NSImage
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(caption, forKey: "caption")
        coder.encode(alignment, forKey: "alignment")
        coder.encode(captionFontName, forKey: "captionFontName")
        coder.encode(captionFontSize, forKey: "captionFontSize")
        coder.encode(captionColor, forKey: "captionColor")
        
        coder.encode(backgroundImage, forKey: "backgroundImage")
        coder.encode(backgroundColorStart, forKey: "backgroundColorStart")
        coder.encode(backgroundColorEnd, forKey: "backgroundColorEnd")
        
        coder.encode(dropShadowStrength, forKey: "dropShadowStrength")
        coder.encode(dropShadowTarget, forKey: "dropShadowTarget")
        
        coder.encode(screenshot, forKey: "screenshot")
    }
}
