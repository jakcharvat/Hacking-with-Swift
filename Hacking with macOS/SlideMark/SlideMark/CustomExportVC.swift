//
//  CustomExportVC.swift
//  SlideMark
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class CustomExportVC: NSViewController {
    
    @IBOutlet var widthTF: NSTextField!
    @IBOutlet var heightTF: NSTextField!
    @IBOutlet var durationTF: NSTextField!
    @IBOutlet var watermarkTF: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFormatters()
    }
    
    
    private func initFormatters() {
        [ widthTF, heightTF, durationTF ].forEach { tf in
            tf.formatter = OnlyIntTFFormatter(for: tf)
        }
    }
    
    
    @IBAction func exportClicked(_ sender: NSButton) {
        
        if widthTF.stringValue.isEmpty { widthTF.stringValue = "1920" }
        if heightTF.stringValue.isEmpty { heightTF.stringValue = "1080" }
        if durationTF.stringValue.isEmpty { durationTF.stringValue = "8" }
        if watermarkTF.stringValue.isEmpty { watermarkTF.stringValue = "© 2020 jakcharvat" }
        
        if let window = view.window {
            window.sheetParent?.endSheet(window, returnCode: .OK)
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        if let window = view.window {
            window.sheetParent?.endSheet(window, returnCode: .cancel)
        }
    }
}


extension CustomExportVC: NSTextFieldDelegate {
    
}


class OnlyIntTFFormatter: NumberFormatter {
    
    weak var tf: NSTextField?
    
    init(for tf: NSTextField?) {
        self.tf = tf
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.isEmpty { return true }
        
        if Int(partialString) != nil { return true }
        
        tf?.layer?.add(createBounceAnimation(), forKey: "bounceAnimation")
        return false
    }
    
    
    private func createBounceAnimation() -> CAKeyframeAnimation {
        let bounce = CAKeyframeAnimation()
        bounce.keyPath = "position.x"
        bounce.isAdditive = true
        bounce.duration = 0.4
        
        bounce.values = [ 10, -7, 4, -2, 0 ]
        return bounce
    }
}
