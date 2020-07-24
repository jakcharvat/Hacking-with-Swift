//
//  NewGameVC.swift
//  Project34
//
//  Created by Jakub Charvat on 16/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit
import SnapKit

class NewGameVC: UIViewController {
    
    var stackView: UIStackView!
    var difficultyRow: UIStackView!
    var playAgainstAI = true
    var opponentDifficulty = OpponentDifficulty.Intermediate

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        createUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        configureConstraints()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    func createUI() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 120
        stackView.alignment = .center
        view.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 64)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = "Four in a Row"
        stackView.addArrangedSubview(titleLabel)
        
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(toggleOpponentType(_:)), for: .valueChanged)
        
        let toggleLabel = UILabel()
        toggleLabel.font = .preferredFont(forTextStyle: .body)
        toggleLabel.text = "Play against AI:"
        
        let row1 = UIStackView(arrangedSubviews: [toggleLabel, toggle])
        row1.spacing = 30
        row1.axis = .horizontal
        
        let difficultyLabel = UILabel()
        difficultyLabel.font = .preferredFont(forTextStyle: .body)
        difficultyLabel.text = "Opponent Difficulty:"
        
        let difficultySelector = UISegmentedControl(items: OpponentDifficulty.allCases.map(\.rawValue))
        difficultySelector.selectedSegmentIndex = 1
        difficultySelector.addTarget(self, action: #selector(changeOpponentDifficulty(_:)), for: .valueChanged)
        
        difficultyRow = UIStackView(arrangedSubviews: [difficultyLabel, difficultySelector])
        difficultyRow.spacing = 30
        difficultyRow.axis = .horizontal
        
        let column = UIStackView(arrangedSubviews: [row1, difficultyRow])
        column.axis = .vertical
        column.spacing = 20
        stackView.addArrangedSubview(column)
        
        let playButton = UIButton(type: .roundedRect)
        playButton.setTitle("Play!", for: .normal)
        playButton.addTarget(self, action: #selector(playPressed(_:)), for: .touchUpInside)
        playButton.backgroundColor = .systemBlue
        playButton.setTitleColor(.white, for: .normal)
        playButton.layer.cornerRadius = 10
        stackView.addArrangedSubview(playButton)
        
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
        
    }
    
    func configureConstraints() {
        stackView.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    @objc func toggleOpponentType(_ sender: UISwitch) {
        playAgainstAI = sender.isOn
        
        UIView.animate(withDuration: 0.3) {
            self.difficultyRow.isHidden = !self.playAgainstAI
            self.difficultyRow.alpha = self.playAgainstAI ? 1 : 0
        }
    }
    
    @objc func changeOpponentDifficulty(_ sender: UISegmentedControl) {
        opponentDifficulty = OpponentDifficulty.allCases[sender.selectedSegmentIndex]
    }

    @objc func playPressed(_ sender: UIButton) {
        guard let gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "game") as? GameVC else { return }
        gameVC.useAIOpponent = playAgainstAI
        gameVC.opponentDifficulty = opponentDifficulty
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
}


enum OpponentDifficulty: String, CaseIterable {
    case Beginner, Intermediate, Advanced
}
