//
//  VideoExportManager.swift
//  SlideMark
//
//  Created by Jakub Charvat on 01/06/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import AppKit
import AVFoundation

struct VideoExportManager {
    let viewController: ViewController
    
    func runExport(at size: CGSize, duration: Double = 8.0, watermark: String = "© 2020 Jakcharvat") {
        do {
            try exportMovie(at: size, duration: duration, watermark: watermark)
        } catch {
            print(error)
        }
    }
    
    
    private func exportMovie(at size: NSSize, duration: Double, watermark: String) throws {
        let endTime = CMTime(seconds: duration, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: .zero, end: endTime)
        
        let saveURL = viewController.photosDir.appendingPathComponent("video.mp4")
        let fm = FileManager.default
        
        if fm.fileExists(atPath: saveURL.path) {
            try fm.removeItem(at: saveURL)
        }
        
        let mutableComposition = AVMutableComposition()
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(origin: .zero, size: size)
        
        parentLayer.addSublayer(createVideoLayer(in: parentLayer, composition: mutableComposition, videoComposition: videoComposition, timeRange: timeRange))
        parentLayer.addSublayer(createSlideshow(in: parentLayer.frame, duration: duration))
        parentLayer.addSublayer(createText(watermark, in: parentLayer.frame))
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange
        videoComposition.instructions = [ instruction ]
        
        let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)!
        
        exportSession.outputURL = saveURL
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = .mp4
        
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                self.exportFinished(error: exportSession.error)
            }
        }
    }
    
    
    private func createVideoLayer(in parentLayer: CALayer, composition: AVMutableComposition, videoComposition: AVMutableVideoComposition, timeRange: CMTimeRange) -> CALayer {
        let videoLayer = CALayer()
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        let mutableCompositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let trackURL = Bundle.main.url(forResource: "black", withExtension: "mp4")!
        let asset = AVAsset(url: trackURL)
        
        let track = asset.tracks[0]
        
        try! mutableCompositionVideoTrack?.insertTimeRange(timeRange, of: track, at: .zero)
        
        return videoLayer
    }
    
    
    private func createSlideshow(in frame: CGRect, duration: CFTimeInterval) -> CALayer {
        let imageLayer = CALayer()
        
        imageLayer.bounds = frame
        imageLayer.position = CGPoint(x: frame.midX, y: frame.midY)
        imageLayer.contentsGravity = .resizeAspectFill
        
        let fadeAnimation = CAKeyframeAnimation(keyPath: "contents")
        fadeAnimation.duration = duration
        fadeAnimation.isRemovedOnCompletion = false
        fadeAnimation.beginTime = AVCoreAnimationBeginTimeAtZero
        
        var values = [NSImage]()
        
        for photo in viewController.photos {
            if let image = NSImage(contentsOfFile: photo.path) {
                values.append(image)
                values.append(image)
            }
        }
        
        fadeAnimation.values = values
        
        imageLayer.add(fadeAnimation, forKey: nil)
        return imageLayer
    }

    
    private func createText(_ text: String, in frame: CGRect) -> CALayer {
        let attrs: [NSAttributedString.Key : Any] = [
            .font: NSFont.boldSystemFont(ofSize: 24),
            .foregroundColor: NSColor.green
        ]
        
        let text = NSAttributedString(string: text, attributes: attrs)
        let textSize = text.size()
        
        let textLayer = CATextLayer()
        textLayer.bounds = CGRect(origin: .zero, size: textSize)
        textLayer.anchorPoint = CGPoint(x: 1, y: 0)
        textLayer.position = CGPoint(x: frame.maxX - 10, y: 10)
        textLayer.string = text
        
        // Usually not needed, but here the text is rendered lazily and misses the first few frames of the video. This line ensures it's loaded before the video starts recording
        textLayer.display()
        
        return textLayer
    }
    
    
    private func exportFinished(error: Error? = nil) {
        let message: String
        
        if let error = error {
            message = "Error: \(error.localizedDescription)"
        } else {
            message = "Success"
        }
        
        let alert = NSAlert()
        alert.messageText = message
        alert.beginSheetModal(for: viewController.view.window!) { _ in }
    }
}
