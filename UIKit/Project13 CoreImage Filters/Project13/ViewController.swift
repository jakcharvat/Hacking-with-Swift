//
//  ViewController.swift
//  Project13
//
//  Created by Jakub Charvat on 30/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var imageBackgroundView: UIView!
    @IBOutlet private var intensitySlider: UISlider!
    @IBOutlet private var filterButton: UIButton!
    
    private var currentImage: UIImage!
    private var context: CIContext!
    private var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNav()
        configureFilters()
    }
}


//MARK: - Config
extension ViewController {
    private func configureNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importImage))
    }
    
    private func configureFilters() {
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
}


//MARK: - Image Selection
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func importImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        imageBackgroundView.alpha = 0
        
        dismiss(animated: true) {
            UIView.animate(withDuration: 0.3) { self.imageBackgroundView.alpha = 1 }
        }
        currentImage = image
        
        let originalImage = CIImage(image: currentImage)
        currentFilter.setValue(originalImage, forKey: kCIInputImageKey)
        
        filterButton.setTitle(currentFilter.name, for: .normal)
        
        applyProcessing()
    }
}


//MARK: - CI Processing
extension ViewController {
    private func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)}
        
        if let cgImage = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            imageView.image = processedImage
        }
    }
    
    private func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let filterName = action.title else { return }
        
        filterButton.setTitle(filterName, for: .normal)
        currentFilter = CIFilter(name: filterName)
        
        let originalImage = CIImage(image: currentImage)
        currentFilter.setValue(originalImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
}


//MARK: - Image Saving
extension ViewController {
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let title: String
        let message: String
        if let error = error {
            title = "Save error"
            message = error.localizedDescription
        } else {
            title = "Saved!"
            message = "Your edited image has been saved to your photos."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}


//MARK: - IBAction
extension ViewController {
    @IBAction private func changeFilter() {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction private func save() {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "No Image", message: "We can't save an image you didn't choose!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction private func intensityChanged() {
        applyProcessing()
    }
    
}

