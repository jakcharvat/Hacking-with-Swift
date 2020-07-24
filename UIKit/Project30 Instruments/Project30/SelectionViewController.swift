//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
	var dirty = false
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none

		loadImages()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
        let image = images[indexPath.row % items.count]
        

		cell.imageView?.image = image

		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: 90, height: 90))).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		navigationController?.pushViewController(vc, animated: true)
	}
}


//MARK: - Documents Caching
extension SelectionViewController {
    func loadImages() {
        (items, images) = loadFromCache() ?? loadAndResizeImagesFromBundle()
    }
    
    
    func loadFromCache() -> ([String], [UIImage])? {
        guard let docDir = getDocumentsPath() else { return nil }
        let fm = FileManager.default
        
        var itemNames = [String]()
        var itemImages = [UIImage]()
        if let tempItemStrings = try? fm.contentsOfDirectory(atPath: docDir.path) {
            
            for string in tempItemStrings {
                if string.hasPrefix("smallImage") {
                    itemNames.append(string)
                }
            }
            
            for name in itemNames {
                if let image = UIImage(contentsOfFile: docDir.appendingPathComponent("\(name)").path) {
                    itemImages.append(image)
                }
            }
            
            itemNames = itemNames.map { $0.replacingOccurrences(of: "smallImage-", with: "") }
            
            if itemNames.count == itemImages.count && !itemNames.isEmpty {
                return (itemNames, itemImages)
            }
            
        }
        
        return nil
    }
    
    func loadAndResizeImagesFromBundle() -> ([String], [UIImage]) {
        let fm = FileManager.default

        var itemNames = [String]()
        var itemImages = [UIImage]()
        let docsDir = getDocumentsPath()
        
        if let tempItems = try? fm.contentsOfDirectory(atPath: Bundle.main.resourcePath!) {
            for name in tempItems {
                if name.range(of: "Large") != nil {
                    itemNames.append(name)
                }
            }
        }
        
        for name in itemNames {
            let small = createSmallImage(for: name)
            itemImages.append(small)
            
            if let docsDir = docsDir {
                let url = docsDir.appendingPathComponent("smallImage-\(name)")
                if let data = small.pngData() {
                    try? data.write(to: url)
                }
            }
            
        }
        
        if !itemNames.isEmpty && itemNames.count == itemImages.count {
            return (itemNames, itemImages)
        }
        
        fatalError("Unable to load images")
    }
    
    func createSmallImage(for item: String) -> UIImage {
        let imageRootName = item.replacingOccurrences(of: "Large", with: "Thumb")
        guard let path = Bundle.main.path(forResource: imageRootName, ofType: nil) else { fatalError() }
        guard let original = UIImage(contentsOfFile: path) else { fatalError() }
        
        let renderRect = CGRect(x: 0, y: 0, width: 90, height: 90)
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)

        let rounded = renderer.image { ctx in
            ctx.cgContext.addEllipse(in: renderRect)
            ctx.cgContext.clip()

            original.draw(in: renderRect)
        }
        
        return rounded
    }
    
    func getDocumentsPath() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
