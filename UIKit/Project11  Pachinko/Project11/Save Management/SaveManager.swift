//
//  SaveManager.swift
//  Project11
//
//  Created by Jakub Charvat on 29/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import SpriteKit
import CoreServices

//MARK: - Save
extension GameScene {
    func saveLevel() {
        guard let boxNodes = children.filter({ $0.name == "box" }) as? [SKSpriteNode] else { return }
        
        let boxes = boxNodes.map { SaveBox(position: normalize(position: $0.position),
                                           size: normalize(size: $0.size),
                                           color: ColorCodable(from: $0.color),
                                           rotation: $0.zRotation) }
        let save = SaveData(boxes: boxes)
        let url = getDocumentsURL().appendingPathComponent("level.json")
        
        guard
            let json = try? JSONEncoder().encode(save),
            let jsonString = String(data: json, encoding: .utf8),
            let _ = try? jsonString.write(to: url, atomically: false, encoding: .utf8) else { return }

        shareFile(at: url)
    }
    
    private func shareFile(at url: URL) {
        guard let gameVC = getGameVC() else { return }
        let popoverView = createPopoverView(in: gameVC, for: saveLabel)
        
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: [ClipboardActivity()])
        ac.popoverPresentationController?.sourceView = popoverView
        ac.excludedActivityTypes = [.copyToPasteboard]
        
        ac.completionWithItemsHandler = { (_, _, _, _) in
            try? FileManager().removeItem(at: url)
            popoverView.removeFromSuperview()
        }
        
        gameVC.present(ac, animated: true)
    }
}


//MARK: - Open
extension GameScene {
    
    func openLevel() {
        resetGame()
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeJSON as String], in: .import)
        guard let gameVC = getGameVC() else { return }
        
        documentPicker.delegate = self
        
        gameVC.present(documentPicker, animated: true)
        
    }
    
    private func loadLevel(from url: URL) {
        
        print(url)
        
        guard
            let jsonString = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(SaveData.self, from: jsonString) else { return }
        
        for box in decoded.boxes {
            let position = denormalize(position: box.position)
            let size = denormalize(size: box.size)
            let color = box.color.uiColor
            let rotation = box.rotation
            
            createBox(at: position, size: size, color: color, rotation: rotation)
        }
    }
}


//MARK: - Utils
extension GameScene {
    private func normalize(position pos: CGPoint, in rect: CGRect? = nil) -> CGPoint {
        let ref = rect ?? frame
        
        let x = (pos.x - ref.minX) / ref.width
        let y = (pos.y - ref.minY) / ref.height
        
        return CGPoint(x: x, y: y)
    }
    
    private func normalize(size s: CGSize, in rect: CGRect? = nil) -> CGSize {
        let ref = rect ?? frame
        
        let w = s.width / ref.width
        let h = s.height / ref.height
        
        return CGSize(width: w, height: h)
    }
    
    private func denormalize(position pos: CGPoint, for rect: CGRect? = nil) -> CGPoint {
        let ref = rect ?? frame
        
        let x = pos.x * ref.width + ref.minX
        let y = pos.y * ref.height + ref.minY
        
        return CGPoint(x: x, y: y)
    }
    
    private func denormalize(size s: CGSize, for rect: CGRect? = nil) -> CGSize {
        let ref = rect ?? frame
        
        let w = s.width * ref.width
        let h = s.height * ref.height
        
        return CGSize(width: w, height: h)
    }
    
    private func getDocumentsURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }
    
    private func createPopoverView(in vc: GameViewController, for parentView: SKNode) -> UIView {
        let labelFrame = parentView.frame
        
        let frame = CGRect(x: labelFrame.minX,
                           y: self.frame.height - labelFrame.minY,
                           width: labelFrame.width,
                           height: 0)
        
        let view = UIView(frame: frame)
        vc.view.addSubview(view)
        return view
    }
    
    private func getGameVC() -> GameViewController? {
        return UIApplication.shared.windows.first?.rootViewController as? GameViewController
    }
}


//MARK: - Document Picker
extension GameScene: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        loadLevel(from: url)
    }
}
