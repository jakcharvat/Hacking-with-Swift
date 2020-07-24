//
//  ViewController.swift
//  Screenable
//
//  Created by Jakub Charvat on 04/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa
import Combine

class ViewController: NSViewController {

    @IBOutlet var imageView: NSImageView!
    @IBOutlet var caption: NSTextView!
    @IBOutlet var alignment: NSSegmentedControl!
    @IBOutlet var fontName: NSPopUpButton!
    @IBOutlet var fontSize: NSPopUpButton!
    @IBOutlet var fontColor: NSColorWell!
    
    @IBOutlet var backgroundImage: NSPopUpButton!
    @IBOutlet var backgroundColorStart: NSColorWell!
    @IBOutlet var backgroundColorEnd: NSColorWell!
    
    @IBOutlet var dropShadowStrength: NSSegmentedControl!
    @IBOutlet var dropShadowTarget: NSSegmentedControl!
    
    var screenshot: NSImage?
    
    @Published var captionText = ""
    var captionSink: AnyCancellable?
    
    var document: Document {
        let document = view.window?.windowController?.document as? Document
        assert(document != nil, "Unable to find document for view controller")
        return document!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(importScreenshot))
        imageView.addGestureRecognizer(recognizer)
        
        loadFonts()
        loadBackgroundImages()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateUI(from: document)
        generatePreview()
        
        captionSink = $captionText
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [unowned self] caption in
                self.setCaptionText(to: caption)
            }
        
        captionText = document.screenshot.caption
    }
    
    func loadFonts() {
        guard let fontsURL = Bundle.main.url(forResource: "fonts", withExtension: nil) else { return }
        guard let fontsString = try? String(contentsOf: fontsURL) else { return }
        
        let fonts = fontsString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        for font in fonts {
            if font.hasPrefix(" ") {
                // Font variation
                let item = NSMenuItem(title: font, action: #selector(changeFontName(_:)), keyEquivalent: "")
                item.target = self
                fontName.menu?.addItem(item)
            } else {
                // Font family
                let item = NSMenuItem(title: font, action: nil, keyEquivalent: "")
                item.target = self
                item.isEnabled = false
                fontName.menu?.addItem(item)
            }
        }
        
        fontName.selectItem(at: 1)
    }
    
    func loadBackgroundImages() {
        let allImages = ["Antique Wood", "Autumn Leaves", "Autumn Sunset", "Autumn by the Lake", "Beach and Palm Tree", "Blue Skies", "Bokeh (Blue)", "Bokeh (Golden)", "Bokeh (Green)", "Bokeh (Orange)", "Bokeh (Rainbow)", "Bokeh (White)", "Burning Fire", "Cherry Blossom", "Coffee Beans", "Cracked Earth", "Geometric Pattern 1", "Geometric Pattern 2", "Geometric Pattern 3", "Geometric Pattern 4", "Grass", "Halloween", "In the Forest", "Jute Pattern", "Polka Dots (Purple)", "Polka Dots (Teal)", "Red Bricks", "Red Hearts", "Red Rose", "Sandy Beach", "Sheet Music", "Snowy Mountain", "Spruce Tree Needles", "Summer Fruits", "Swimming Pool", "Tree Silhouette", "Tulip Field", "Vintage Floral", "Zebra Stripes"]
        
        for image in allImages {
            let item = NSMenuItem(title: image, action: #selector(changeBackgroundImage(_:)), keyEquivalent: "")
            item.target = self
            backgroundImage.menu?.addItem(item)
        }
    }
    
    func updateUI(from document: Document) {
        caption.string = document.screenshot.caption
        alignment.selectedSegment = document.screenshot.alignment
        fontName.selectItem(withTitle: document.screenshot.captionFontName)
        fontSize.selectItem(withTag: document.screenshot.captionFontSize)
        fontColor.color = document.screenshot.captionColor
        
        if !document.screenshot.backgroundImage.isEmpty {
            backgroundImage.selectItem(withTitle: document.screenshot.backgroundImage)
        } else {
            backgroundImage.selectItem(withTag: 999)
        }
        
        backgroundColorStart.color = document.screenshot.backgroundColorStart
        backgroundColorEnd.color = document.screenshot.backgroundColorEnd
        
        dropShadowStrength.selectedSegment = document.screenshot.dropShadowStrength
        dropShadowTarget.selectedSegment = document.screenshot.dropShadowTarget
        
        screenshot = document.screenshot.screenshot
        imageView.image = screenshot
    }
}


//MARK: - Generating Previews
extension ViewController {
    func generatePreview() {
        let image = NSImage(size: CGSize(width: 1242, height: 2208), flipped: false) { [unowned self] rect -> Bool in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            
            self.clearBackground(in: rect, ctx: ctx)
            self.drawBackgroundImage(in: rect)
            self.drawColorOverlay(in: rect)
            let captionHeight = self.drawCaption(in: rect, ctx: ctx)
            self.drawDevice(in: rect, ctx: ctx, captionHeight: captionHeight)
            self.drawScreenshot(in: rect, ctx: ctx, captionHeight: captionHeight)
            
            return true
        }
        
        imageView.image = image
    }
    
    func clearBackground(in rect: NSRect, ctx: CGContext) {
        ctx.setFillColor(NSColor.white.cgColor)
        ctx.fill(rect)
    }
    
    func drawBackgroundImage(in rect: NSRect) {
        if backgroundImage.selectedTag() == 999 { return }
        guard let title = backgroundImage.titleOfSelectedItem else { return }
        guard let image = NSImage(named: title) else { return }
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    }
    
    func drawColorOverlay(in rect: NSRect) {
        let gradient = NSGradient(starting: backgroundColorStart.color, ending: backgroundColorEnd.color)
        gradient?.draw(in: rect, angle: -90)
    }
    
    func createCaptionAttrs() -> [NSAttributedString.Key : Any]? {
        let ps = NSMutableParagraphStyle()
        let alignments: [Int : NSTextAlignment] = [ 0: .left, 1: .center, 2: .right, 3: .justified ]
        ps.alignment = alignments[alignment.selectedSegment] ?? .center
        
        let fontSizes: [Int : CGFloat] = [ 0: 48, 1: 56, 2: 64, 3: 72, 4: 80, 5: 96, 6: 128 ]
        guard let baseFontSize = fontSizes[fontSize.selectedTag()] else { return nil }
        
        let selectedFontName = fontName.selectedItem?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? "HelveticaNeue-Medium"
        guard let font = NSFont(name: selectedFontName, size: baseFontSize) else { return nil }
        let color = fontColor.color
        
        let dict: [NSAttributedString.Key : Any] = [
            .paragraphStyle: ps,
            .font: font,
            .foregroundColor: color
        ]
        
        return dict
    }
    
    func setShadow() {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowColor = .black
        shadow.shadowBlurRadius = 50
        
        shadow.set()
    }
    
    func drawCaption(in rect: NSRect, ctx: CGContext) -> CGFloat {
        if dropShadowStrength.selectedSegment != 0 {
            if dropShadowTarget.selectedSegment != 1 {
                // If shadow is enabled and set to "text" or "both" then enable it
                setShadow()
            }
        }
        
        let string = caption.textStorage?.string ?? ""
        
        let captionFrame = rect.insetBy(dx: 40, dy: 20)
        
        let captionAttrs = createCaptionAttrs()
        let attrString = NSAttributedString(string: string, attributes: captionAttrs)
        
        attrString.draw(in: captionFrame)
        
        if dropShadowStrength.selectedSegment == 2 {
            if dropShadowTarget.selectedSegment != 1 {
                // If the shadow is set to "strong" then redraw the string to darken the shadow
                attrString.draw(in: captionFrame)
            }
        }
        
        let noShadow = NSShadow()
        noShadow.set()
        
        let availSize = NSSize(width: captionFrame.width, height: .greatestFiniteMagnitude)
        let textFrame = attrString.boundingRect(with: availSize, options: [ .usesLineFragmentOrigin, .usesFontLeading ])
        
        return textFrame.height
    }
    
    func drawDevice(in rect: NSRect, ctx: CGContext, captionHeight: CGFloat) {
        guard let image = NSImage(named: "iPhone") else { return }
        
        let offsetX = (rect.size.width - image.size.width) / 2
        var offsetY = (rect.size.height - image.size.height) / 2
        offsetY -= captionHeight
        
        if dropShadowStrength.selectedSegment != 0 {
            if dropShadowTarget.selectedSegment != 0 {
                setShadow()
            }
        }
        
        image.draw(at: CGPoint(x: offsetX, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
        
        if dropShadowStrength.selectedSegment == 2 {
            if dropShadowTarget.selectedSegment != 0 {
                image.draw(at: CGPoint(x: offsetX, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
            }
        }
        
        let noShadow = NSShadow()
        noShadow.set()
    }
    
    func drawScreenshot(in rect: NSRect, ctx: CGContext, captionHeight: CGFloat) {
        guard let screenshot = screenshot else { return }
        screenshot.size = CGSize(width: 891, height: 1584)
        
        let offsetY = 314 - captionHeight
        screenshot.draw(at: CGPoint(x: 176, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
    }
}


//MARK: - Screenshot Importing
extension ViewController {
    @objc func importScreenshot() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = [ "png", "jpg" ]
        
        panel.begin { [unowned self] result in
            if result == .OK {
                guard let imageURL = panel.url else { return }
                self.screenshot = NSImage(contentsOf: imageURL)
                self.document.screenshot.screenshot = self.screenshot
                self.generatePreview()
            }
        }
    }
}


//MARK: - Actions
extension ViewController {
    @objc func changeFontName(_ sender: NSMenuItem) {
        setFontName(to: fontName.titleOfSelectedItem ?? "")
    }
    
    @objc func setFontName(to name: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setFontName(to:)), object: document.screenshot.captionFontName)
        
        document.screenshot.captionFontName = name
        fontName.selectItem(withTitle: document.screenshot.captionFontName)
        
        generatePreview()
    }
    
    @IBAction func changeAlignment(_ sender: NSSegmentedControl) {
        setAlignment(to: String(alignment.selectedSegment))
    }
    
    @objc func setAlignment(to alignment: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setAlignment(to:)), object: String(document.screenshot.alignment))
        
        document.screenshot.alignment = Int(alignment)!
        self.alignment.selectedSegment = document.screenshot.alignment
        
        generatePreview()
    }
    
    @IBAction func changeFontSize(_ sender: NSMenuItem) {
        setFontSize(to: String(fontSize.selectedTag()))
    }
    
    @objc func setFontSize(to size: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setFontSize(to:)), object: String(document.screenshot.captionFontSize))
        
        document.screenshot.captionFontSize = Int(size)!
        fontSize.selectItem(withTag: document.screenshot.captionFontSize)
        
        generatePreview()
    }
    
    @IBAction func changeFontColor(_ sender: NSColorWell) {
        setFontColor(to: fontColor.color)
    }
    
    @objc func setFontColor(to color: NSColor) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setFontColor(to:)), object: document.screenshot.captionColor)
        
        document.screenshot.captionColor = color
        fontColor.color = color
        
        generatePreview()
    }
    
    @IBAction func changeBackgroundImage(_ sender: NSMenuItem) {
        if backgroundImage.selectedTag() == 999 {
            setBackgroundImage(to: "")
        } else {
            setBackgroundImage(to: backgroundImage.titleOfSelectedItem ?? "")
        }
    }
    
    @objc func setBackgroundImage(to image: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundImage(to:)), object: document.screenshot.backgroundImage)
        
        document.screenshot.backgroundImage = image
        backgroundImage.selectItem(withTitle: image)
        
        generatePreview()
    }
    
    @IBAction func changeBackgroundColorStart(_ sender: NSColorWell) {
        setBackgroundColorStart(to: backgroundColorStart.color)
    }
    
    @objc func setBackgroundColorStart(to color: NSColor) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundColorStart(to:)), object: document.screenshot.backgroundColorStart)
        
        document.screenshot.backgroundColorStart = color
        backgroundColorStart.color = color
        
        generatePreview()
    }
    
    @IBAction func changeBackgroundColorEnd(_ sender: NSColorWell) {
        setBackgroundColorEnd(to: backgroundColorEnd.color)
    }
    
    @objc func setBackgroundColorEnd(to color: NSColor) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundColorEnd(to:)), object: document.screenshot.backgroundColorEnd)
        
        document.screenshot.backgroundColorEnd = color
        backgroundColorEnd.color = color
        
        generatePreview()
    }
    
    @IBAction func changeDropShadowStrength(_ sender: NSSegmentedControl) {
        setDropShadowStrength(to: String(dropShadowStrength.selectedSegment))
    }
    
    @objc func setDropShadowStrength(to strength: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setDropShadowStrength(to:)), object: String(document.screenshot.dropShadowStrength))
        
        document.screenshot.dropShadowStrength = Int(strength)!
        dropShadowStrength.selectedSegment = document.screenshot.dropShadowStrength
        
        generatePreview()
    }
    
    @IBAction func changeDropShadowTarget(_ sender: NSSegmentedControl) {
        setDropShadowTarget(to: String(dropShadowTarget.selectedSegment))
    }
    
    @objc func setDropShadowTarget(to target: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setDropShadowTarget(to:)), object: String(document.screenshot.dropShadowTarget))
        
        document.screenshot.dropShadowTarget = Int(target)!
        dropShadowTarget.selectedSegment = document.screenshot.dropShadowTarget
        
        generatePreview()
    }
    
    
    @IBAction func export(_ sender: NSButton) {
        guard let image = imageView.image else { return }
        guard let tiff = image.tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: tiff) else { return }
        guard let png = imageRep.representation(using: .png, properties: [:]) else { return }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = [ "png" ]
        panel.begin { result in
            if result == .OK {
                guard let url = panel.url else { return }
                
                do {
                    try png.write(to: url)
                } catch {
                    print(error)
                }
            }
        }
    }
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        captionText = caption.string
        generatePreview()
    }
    
    @objc func setCaptionText(to text: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setCaptionText(to:)), object: document.screenshot.caption)
        
        document.screenshot.caption = text
        caption.string = text
        
        generatePreview()
    }
}
