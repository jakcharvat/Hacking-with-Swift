//
//  CollectionManager.swift
//  SlideMark
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import Cocoa

class CollectionManager: NSObject {
    private let collectionView: NSCollectionView
    
    weak var viewController: ViewController?
    
    var itemsBeingDragged: Set<IndexPath>?
    
    init(for collectionView: NSCollectionView) {
        self.collectionView = collectionView
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        configureDragAndDrop()
    }
}


//MARK: - Data Source
extension CollectionManager: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewController?.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Photo"), for: indexPath)
        guard let vc = viewController else { return item }
        guard let photoItem = item as? Photo else { return item }
        
        let image = NSImage(contentsOf: vc.photos[indexPath.item])
        photoItem.imageView?.image = image
        
        return photoItem
    }
}


//MARK: - Delegate
extension CollectionManager: NSCollectionViewDelegate {
    
}


//MARK: - Drag and Drop
extension CollectionManager {
    func configureDragAndDrop() {
        collectionView.registerForDraggedTypes([ .URL ])
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        return itemsBeingDragged == nil ? .copy : .move
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        itemsBeingDragged = indexPaths
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        return viewController?.photos[indexPath.item] as NSPasteboardWriting?
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        itemsBeingDragged = nil
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        if let moveItems = itemsBeingDragged?.sorted() {
            performInternalDrag(with: moveItems, to: indexPath)
            return true
        }
        
        let pasteboard = draggingInfo.draggingPasteboard
        guard let items = pasteboard.pasteboardItems else { return false }
        performExternalDrag(with: items, at: indexPath)
        
        return true
    }
    
    
    private func performInternalDrag(with items: [IndexPath], to indexPath: IndexPath) {
        var destinationIndex = indexPath.item
        
        for sourceIndexPath in items.reversed() {
            let sourceIndex = sourceIndexPath.item
            
            if sourceIndex < destinationIndex {
                viewController?.photos.moveItem(from: sourceIndex, to: destinationIndex)
                collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destinationIndex - 1, section: 0))
                
                destinationIndex -= 1
            }
        }
        
        destinationIndex = indexPath.item
        
        for sourceIndexPath in items {
            let sourceIndex = sourceIndexPath.item
            
            if sourceIndex >= destinationIndex {
                viewController?.photos.moveItem(from: sourceIndex, to: destinationIndex)
                collectionView.moveItem(at: sourceIndexPath, to: IndexPath(item: destinationIndex, section: 0))
                
                destinationIndex += 1
            }
        }
    }
    
    
    private func performExternalDrag(with items: [NSPasteboardItem], at indexPath: IndexPath) {
        let fm = FileManager.default
        
        for item in items {
            guard let stringURL = item.string(forType: .fileURL) else { continue }
            guard let sourceURL = URL(string: stringURL) else { continue }
            
            guard let destinationURL = viewController?.photosDir.appendingPathComponent(sourceURL.lastPathComponent) else { continue }
            
            do {
                try fm.copyItem(at: sourceURL, to: destinationURL)
            } catch {
                print("Error copying item from: \(sourceURL): \(error)")
                continue
            }
            
            viewController?.photos.insert(destinationURL, at: indexPath.item)
            collectionView.insertItems(at: [ indexPath ])
        }
    }
}
