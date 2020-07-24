//
//  RecordWhistleVC.swift
//  Project33
//
//  Created by Jakub Charvat on 15/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import AVFoundation

class RecordWhistleVC: UIViewController {

    var stackView: UIStackView!
    var recordButton: UIButton!
    var playButton: UIButton!
    
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var whistleUUIDString = UUID().uuidString

    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .gray
        
        createStackView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavbar()
        initAudioRecording()
    }
    
    private func createStackView() {
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func configureNavbar() {
        title = "Record your whistle"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func initAudioRecording() {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            audioSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.showRecordingUI()
                    } else {
                        self.showFailureUI()
                    }
                }
            }
        } catch {
            showFailureUI()
        }
    }
    
    func showRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.isHidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = .preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    
    func showFailureUI() {
        let failLabel = UILabel()
        failLabel.font = .preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        stackView.addArrangedSubview(failLabel)
    }
    
    @objc func recordTapped(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
            
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.playButton.isHidden = true
                self.playButton.alpha = 0
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc func playTapped(_ sender: UIButton) {
        let audioURL = getWhistleURL()
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback Failed", message: "There was a problem playing your whistle; please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
        }
    }
    
    func startRecording() {
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        recordButton.setTitle("Tap to Stop", for: .normal)
        
        let audioURL = getWhistleURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
            if playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = false
                    self.playButton.alpha = 1
                }
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped(_:)))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            let ac = UIAlertController(title: "Recording Failed", message: "There was a problem recording your whistle; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func nextTapped(_ sender: Any) {
        let vc = SelectGenreVC()
        vc.uuidString = whistleUUIDString
        navigationController?.pushViewController(vc, animated: true)
    }
    
    class func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func getWhistleURL() -> URL {
        return RecordWhistleVC
            .getDocumentsDirectory()
            .appendingPathComponent("\(whistleUUIDString).m4a")
    }
    
}


//MARK: - AV Audio Recorder
extension RecordWhistleVC: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
