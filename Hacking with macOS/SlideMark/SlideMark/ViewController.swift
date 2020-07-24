//
//  ViewController.swift
//  SlideMark
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox
import SnapKit

class ViewController: NSViewController {
    
    @IBOutlet private var collectionView: NSCollectionView!
    
    private var collectionManager: CollectionManager!
    
    var photos = [URL]()
    var eventMonitor: Any?
    
    lazy var photosDir: URL = {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = paths[0]
        let saveDir = docsDir.appendingPathComponent("SlideMark")
        
        if !fm.fileExists(atPath: saveDir.path) {
            try? fm.createDirectory(at: saveDir, withIntermediateDirectories: true)
        }
        
        return saveDir
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionManager = CollectionManager(for: collectionView)
        collectionManager.viewController = self
        
        loadImages()
        
        print(photos.map(\.lastPathComponent))
        
//         Remove the click sound on keydown if the delete key was pressed and some items were selected
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return nil }
            
            // Stop event propagation if the delete key was pressed and some items were selected
            if Int(event.keyCode) == kVK_Delete && !self.collectionView.selectionIndexPaths.isEmpty {
                self.deletePressed()
                return nil
            }

            return event
        }
    }
    
    
    private func loadImages() {
        do {
            let fm = FileManager.default
            let files = try fm.contentsOfDirectory(at: photosDir, includingPropertiesForKeys: nil)
            
            for file in files {
                if file.pathExtension == "jpg" || file.pathExtension == "png" {
                    photos.append(file)
                }
            }
        } catch {
            print("Error loading images: \(error)")
        }
    }
    
    
    @IBAction private func runExport(_ sender: NSMenuItem) {
        let exporter = VideoExportManager(viewController: self)
        
        switch sender.tag {
        case 720:
            exporter.runExport(at: CGSize(width: 1280, height: 720))
            
        case 1080:
            exporter.runExport(at: CGSize(width: 1920, height: 1080))
            
        default:
            guard let viewWindow = view.window,
                let wc = storyboard?.instantiateController(withIdentifier: .init("CustomExport")) as? NSWindowController,
                let exportWindow = wc.window,
                let exportVC = exportWindow.contentViewController as? CustomExportVC else { return }
            
            viewWindow.beginSheet(exportWindow) { response in
                switch response {
                case .OK:
                    guard let width = Int(exportVC.widthTF.stringValue),
                        let height = Int(exportVC.heightTF.stringValue),
                        let duration = Double(exportVC.durationTF.stringValue) else { return }
                    let watermark = exportVC.watermarkTF.stringValue
                    let size = CGSize(width: width, height: height)
                    
                    let exporter = VideoExportManager(viewController: self)
                    exporter.runExport(at: size, duration: duration, watermark: watermark)
                    
                default:
                    print("Cancel")
                }
            }
        }
    }


    private func deletePressed() {
        let fm = FileManager.default
        
        for indexPath in collectionView.selectionIndexPaths.sorted().reversed() {
            do {
                try fm.trashItem(at: photos[indexPath.item], resultingItemURL: nil)
                photos.remove(at: indexPath.item)
            } catch {
                print("Failed to delete \(photos[indexPath.item]): \(error)")
            }
        }
        
        collectionView.animator().deleteItems(at: collectionView.selectionIndexPaths)
    }
    
    override func viewWillDisappear() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
