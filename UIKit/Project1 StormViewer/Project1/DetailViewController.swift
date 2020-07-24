//
//  DetailViewController.swift
//  Project1
//
//  Created by Jakub Charvat on 27/04/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var imageName: String?
    var imageIndex: Int?
    var imageCount: Int?
    
    var isNavbarHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image \(imageIndex ?? 0) of \(imageCount ?? 0)"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        guard let imageName = imageName else {
            assertionFailure("No image")
            return
        }
        
        imageView.image = UIImage(named: imageName)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(sender:)))
        tapGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        configureImageViewConstraints(animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(configureImageViewConstraints(animated:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}


//MARK: - Sharing
extension DetailViewController {
    @objc private func shareTapped() {
        guard let image = getImageData(), let imageName = imageName else { return }
        
        let vc = UIActivityViewController(activityItems: [image, imageName], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    private func getImageData() -> Data? {
        
        let includeWatermark = UserDefaults.standard.value(forKey: "settings.watermark") as? Bool ?? true
        
        guard let image = imageView.image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let jpegData = renderer.jpegData(withCompressionQuality: 0.8) { context in
            image.draw(at: .zero)
            
            if includeWatermark {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .right
                let string = "Exported from Storm Viewer"
                let attrs: [NSAttributedString.Key : Any] = [
                    .paragraphStyle: paragraphStyle,
                    .font: UIFont.systemFont(ofSize: 34),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                ]
                
                let rect = CGRect(x: 0, y: image.size.height - 60, width: image.size.width, height: 60).insetBy(dx: 10, dy: 10)
                let attributedString = NSAttributedString(string: string, attributes: attrs)
                attributedString.draw(with: rect, options: .usesLineFragmentOrigin, context: nil)
            }
        }
        
        return jpegData
    }
}


//MARK: - Tap Handling
extension DetailViewController {
    @objc private func imageViewTapped(sender: UITapGestureRecognizer) {
        isNavbarHidden.toggle()
        navigationController?.setNavigationBarHidden(isNavbarHidden, animated: true)
        
        configureImageViewConstraints()
    }
    
    @objc func configureImageViewConstraints(animated: Bool = true) {
        
        let backgroundColor: UIColor
        if isNavbarHidden {
            
            guard let imageSize = imageView.image?.size else { return }
            let imageAspectRatio = imageSize.width / imageSize.height
            
            imageView.snp.remakeConstraints { (make) in
                // force it to not exceed the view's size
                make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide)
                make.leading.greaterThanOrEqualTo(view)
                make.bottom.trailing.lessThanOrEqualTo(view)
                
                // make it try to take up as much space as it can
                make.size.equalTo(view).priority(.medium)
                
                // force it into a fixed aspect ratio to match that of the image
                make.width.equalTo(imageView.snp.height).multipliedBy(imageAspectRatio)
                
                // centre it along the axis where it doesn't take up all available space
                make.center.equalTo(view).priority(.high)
            }
            
            backgroundColor = .black
            
        } else {
            imageView.snp.remakeConstraints { (make) in
                make.leading.trailing.bottom.equalTo(view)
                make.top.equalTo(view.safeAreaLayoutGuide)
            }
            
            backgroundColor = .systemBackground
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.view.backgroundColor = backgroundColor
                self.view.layoutIfNeeded()
            }) { _ in }
        } else {
            view.layoutIfNeeded()
            view.backgroundColor = backgroundColor
        }
    }
}
