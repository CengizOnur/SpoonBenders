//
//  GameVC.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 17.12.2021.
//

import Foundation
import UIKit

final class GameVC: UIViewController {
    
    private var game: SpoonBenders!
    
    private var animationManager: AnimationManager!
    private var soundManager: SoundManager!
    
    init(game: SpoonBenders, animationManager: AnimationManager, soundManager: SoundManager) {
        self.game = game
        self.animationManager = animationManager
        self.soundManager = soundManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var collectionViews: [UICollectionView] = []
    private var selectedItems: [UICollectionView : [Int]] = [:]
    private var moves: [String : [UICollectionView : Int]] = [:]
    
    private var playerViews: [PlayerView] = []
    private var playerViewsSizes: [CGSize] = [CGSize(), CGSize(), CGSize(), CGSize()]
    
    private lazy var quitButton: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, title: nil, image: UIImage(systemName: "xmark"), imageSize: 24)
        button.addTarget(self, action: #selector(quitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var soundButton: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, title: nil, image: UIImage(systemName: "speaker.wave.2"), imageSize: 24)
        button.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var timer = Timer()
    
    private var time = 6 {
        didSet {
            let timeLog = time - 1
            guard timeLog > -1 else { return }
            timeLabel.text = String(timeLog)
        }
    }
    
    private lazy var timeLabel: CustomLabel = {
        let label = CustomLabel(textAlignment: .center)
        label.text = "6"
        label.font = label.font.withSize(24)
        label.textColor = game.isMyTurn ? .systemGreen : .white
        return label
    }()
    
//    private let gradientLayer = CAGradientLayer()
    
    private var initialSetupDone = false
    private var alertPresented = false
    
    private let verticalInset: CGFloat = 4
    private let horizontalInset: CGFloat = 4

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: - ConfigureUI
    
    // Layouts OneVSOne
    private func layoutPortraitOneVsOne(size: CGSize) {
        let constant = floor(size.width / 11) * 1.5
        let playerViewOneWidth = floor(constant * 2.5)
        let playerViewOneHeight = floor(constant * 6)
        
        let playerViewTwoWidth = floor(constant * 2.5)
        let playerViewTwoHeight = floor(constant * 6)
        
        // Set subviews sizes
        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        portraitConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                        
            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            playerViews[1].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ]
    }
    
    
    private func layoutLandscapeOneVsOne(size: CGSize) {
        let constant = floor(size.height / 11 / 3) * 1.25
        let playerViewOneHeight = floor(constant * 10 + 15)
        let playerViewOneWidth = floor(constant * 3 * 4.5)

        let playerViewTwoHeight = floor(constant * 10 + 15)
        let playerViewTwoWidth = floor(constant * 3 * 4.5)
        
        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        // Set subviews sizes
        landscapeConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            playerViews[0].centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            playerViews[1].centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ]
    }
    
    
    // Layouts TwoVSTwo
    private func layoutPortraitTwoVsTwo(size: CGSize) {
        let constant = floor(size.width / 11) * 0.8
        
        let playerViewOneWidth = floor(constant * 2.5)
        let playerViewOneHeight = floor(constant * 6)
        
        let playerViewTwoWidth = floor(constant * 2.5)
        let playerViewTwoHeight = floor(constant * 6)
        
        let playerViewThreeWidth = floor(constant * 2.5)
        let playerViewThreeHeight = floor(constant * 6)
        
        let playerViewFourWidth = floor(constant * 2.5)
        let playerViewFourHeight = floor(constant * 6)
        
        // Set subviews sizes
        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        playerViewsSizes[2].width = playerViewThreeWidth
        playerViewsSizes[2].height = playerViewThreeHeight
        
        playerViewsSizes[3].width = playerViewFourWidth
        playerViewsSizes[3].height = playerViewFourHeight
        
        portraitConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -size.height / 4),
                        
            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            playerViews[1].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: size.height / 4),
            
            playerViews[2].widthAnchor.constraint(equalToConstant: playerViewThreeWidth),
            playerViews[2].heightAnchor.constraint(equalToConstant: playerViewThreeHeight),
            playerViews[2].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            playerViews[2].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -size.height / 4),
                        
            playerViews[3].widthAnchor.constraint(equalToConstant: playerViewFourWidth),
            playerViews[3].heightAnchor.constraint(equalToConstant: playerViewFourHeight),
            playerViews[3].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            playerViews[3].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: size.height / 4),
        ]
    }
    
    
    private func layoutLandscapeTwoVsTwo(size: CGSize) {
        let constant = floor(size.height / 11 / 3) * 1.2
        
        let playerViewOneHeight = floor(constant * 10 + 15)
        let playerViewOneWidth = floor(constant * 3 * 4.5)
        
        let playerViewTwoHeight = floor(constant * 10 + 15)
        let playerViewTwoWidth = floor(constant * 3 * 4.5)
        
        let playerViewThreeHeight = floor(constant * 10 + 15)
        let playerViewThreeWidth = floor(constant * 3 * 4.5)
        
        let playerViewFourHeight = floor(constant * 10 + 15)
        let playerViewFourWidth = floor(constant * 3 * 4.5)

        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        playerViewsSizes[2].width = playerViewThreeWidth
        playerViewsSizes[2].height = playerViewThreeHeight
        
        playerViewsSizes[3].width = playerViewFourWidth
        playerViewsSizes[3].height = playerViewFourHeight
        
        // Set subviews sizes
        landscapeConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -size.height / 4),

            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            playerViews[1].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: size.height / 4),
            
            playerViews[2].widthAnchor.constraint(equalToConstant: playerViewThreeWidth),
            playerViews[2].heightAnchor.constraint(equalToConstant: playerViewThreeHeight),
            playerViews[2].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            playerViews[2].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -size.height / 4),
                        
            playerViews[3].widthAnchor.constraint(equalToConstant: playerViewFourWidth),
            playerViews[3].heightAnchor.constraint(equalToConstant: playerViewFourHeight),
            playerViews[3].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            playerViews[3].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: size.height / 4),
        ]
    }
    
    
    // Layouts Ffa
    private func layoutPortraitFfa(size: CGSize) {
        let constant = floor(size.width / 11)
        
        let playerViewOneWidth = floor(constant * 2.5)
        let playerViewOneHeight = floor(constant * 6)
        
        let playerViewTwoHeight = floor(constant / 3 * 10 + 15)
        let playerViewTwoWidth = floor(constant / 3 * 3 * 4.5)
        
        let playerViewThreeWidth = floor(constant * 2.5)
        let playerViewThreeHeight = floor(constant * 6)
        
        let playerViewFourHeight = floor(constant / 3 * 10 + 15)
        let playerViewFourWidth = floor(constant / 3 * 3 * 4.5)
        
        // Set subviews sizes
        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        playerViewsSizes[2].width = playerViewThreeWidth
        playerViewsSizes[2].height = playerViewThreeHeight
        
        playerViewsSizes[3].width = playerViewFourWidth
        playerViewsSizes[3].height = playerViewFourHeight
        
        portraitConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                        
            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            playerViews[1].centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            playerViews[2].widthAnchor.constraint(equalToConstant: playerViewThreeWidth),
            playerViews[2].heightAnchor.constraint(equalToConstant: playerViewThreeHeight),
            playerViews[2].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            playerViews[2].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                        
            playerViews[3].widthAnchor.constraint(equalToConstant: playerViewFourWidth),
            playerViews[3].heightAnchor.constraint(equalToConstant: playerViewFourHeight),
            playerViews[3].bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            playerViews[3].centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ]
    }
    
    
    private func layoutLandscapeFfa(size: CGSize) {
        let constant = floor(size.height / 11)
        
        let playerViewOneWidth = floor(constant * 2.5)
        let playerViewOneHeight = floor(constant * 6)
        
        let playerViewTwoHeight = floor(constant / 3 * 10 + 15)
        let playerViewTwoWidth = floor(constant / 3 * 3 * 4.5)
        
        let playerViewThreeWidth = floor(constant * 2.5)
        let playerViewThreeHeight = floor(constant * 6)
        
        let playerViewFourHeight = floor(constant / 3 * 10 + 15)
        let playerViewFourWidth = floor(constant / 3 * 3 * 4.5)
        
        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        playerViewsSizes[2].width = playerViewThreeWidth
        playerViewsSizes[2].height = playerViewThreeHeight
        
        playerViewsSizes[3].width = playerViewFourWidth
        playerViewsSizes[3].height = playerViewFourHeight
        
        // Set subviews sizes
        landscapeConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            playerViews[1].centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                        
            playerViews[2].widthAnchor.constraint(equalToConstant: playerViewThreeWidth),
            playerViews[2].heightAnchor.constraint(equalToConstant: playerViewThreeHeight),
            playerViews[2].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            playerViews[2].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            playerViews[3].widthAnchor.constraint(equalToConstant: playerViewFourWidth),
            playerViews[3].heightAnchor.constraint(equalToConstant: playerViewFourHeight),
            playerViews[3].bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            playerViews[3].centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ]
    }
    
    
    private func configureTimeLabel() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        view.addSubview(timeLabel)
        
        timeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: timeLabel.widthAnchor).isActive = true
        timeLabel.layer.cornerRadius = 15
        timeLabel.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
    
    
    private func configureSettingsButton() {
        view.addSubview(quitButton)
        
        quitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        quitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        quitButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        quitButton.heightAnchor.constraint(equalTo: quitButton.widthAnchor).isActive = true
        quitButton.layer.cornerRadius = 15
        quitButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
    
    
    private func configureSoundButton() {
        view.addSubview(soundButton)
        
        soundButton.leadingAnchor.constraint(equalTo: quitButton.trailingAnchor, constant: 10).isActive = true
        soundButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        soundButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        soundButton.heightAnchor.constraint(equalTo: soundButton.widthAnchor).isActive = true
        soundButton.layer.cornerRadius = 15
        soundButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
    
    
    private func invalidateOldConstraints() {
        if portraitConstraints.count > 0 && portraitConstraints[0].isActive {
            NSLayoutConstraint.deactivate(portraitConstraints)
        }
        if landscapeConstraints.count > 0 && landscapeConstraints[0].isActive {
            NSLayoutConstraint.deactivate(landscapeConstraints)
        }
    }
    
    
    private func configureLayoutOneVsOne(size: CGSize) {
        if size.height > size.width {
            layoutPortraitOneVsOne(size: size)
            NSLayoutConstraint.activate(portraitConstraints)
            let positions: [Position] = [.leftOrTop, .rightOrBottom]
            configureLayoutHelper(accordingly: positions)
        } else {
            layoutLandscapeOneVsOne(size: size)
            NSLayoutConstraint.activate(landscapeConstraints)
            let positions: [Position] = [.rightOrBottom, .leftOrTop]
            configureLayoutHelper(accordingly: positions)
        }
    }
    
    
    private func configureLayoutTwoVsTwo(size: CGSize) {
        if size.height > size.width {
            layoutPortraitTwoVsTwo(size: size)
            NSLayoutConstraint.activate(portraitConstraints)
            let positions: [Position] = [.leftOrTop, .leftOrTop, .rightOrBottom, .rightOrBottom]
            configureLayoutHelper(accordingly: positions)
        } else {
            layoutLandscapeTwoVsTwo(size: size)
            NSLayoutConstraint.activate(landscapeConstraints)
            let positions: [Position] = [.leftOrTop, .leftOrTop, .leftOrTop, .leftOrTop]
            configureLayoutHelper(accordingly: positions)
        }
    }
    
    
    private func configureLayoutFfa(size: CGSize) {
        if size.height > size.width {
            layoutPortraitFfa(size: size)
            NSLayoutConstraint.activate(portraitConstraints)
            let positions: [Position] = [.leftOrTop, .leftOrTop, .rightOrBottom, .rightOrBottom]
            configureLayoutHelper(accordingly: positions)
        } else {
            layoutLandscapeFfa(size: size)
            NSLayoutConstraint.activate(landscapeConstraints)
            let positions: [Position] = [.leftOrTop, .leftOrTop, .rightOrBottom, .rightOrBottom]
            configureLayoutHelper(accordingly: positions)
        }
    }
    
    
    private func configureLayoutHelper(accordingly positions: [Position]) {
        for i in 0 ..< playerViews.count {
            playerViews[i].updateLayout(size: playerViewsSizes[i], position: positions[i])
        }
        view.layoutIfNeeded()
        
        guard game.gameMode != .ffa else { return }
        showCurrentPlayer()
    }
    
    
    private func layoutAppropriatelyForGameMode(size: CGSize) {
//        gradientLayer.frame = view.bounds
        
        switch game.gameMode {
        case .oneVsOne:
            playerViews[0].bendersPosition = .left
            configureLayoutOneVsOne(size: size)
        case .twoVsTwo:
            playerViews[0].bendersPosition = .left
            playerViews[1].bendersPosition = .left
            configureLayoutTwoVsTwo(size: size)
        case .ffa:
            playerViews[0].bendersPosition = .left
            configureLayoutFfa(size: size)
        }
    }
    
    
    private func setUpHelper(_ playerOneCode: String, numberOfPlayers: Int) {
        for i in 0 ..< numberOfPlayers {
            let playerCode = game.trios[i]
            let avatarName = game.playersAndAvatars[playerCode]!
            playerViews.append(PlayerView(playerCode: playerOneCode, collectionViewOwnerPlayerCode: playerCode, avatarImage: UIImage(named: "avatars/\(avatarName)")!, nickname: game.playersAndNicknames[playerCode]!, benders: game.benders[i]))
        }
        
        playerViews.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self
            collectionViews.append($0.collectionView)
        }
        
        configureSettingsButton()
        configureSoundButton()
        
        if game.gameMode != .ffa {
            configureTimeLabel()
            if game.isMyTurn { soundManager.playSound() }
        }
    }
    
    
    private func showCurrentPlayer() {
        let currentPlayerIndex = game.getCurrentPlayersLocalIndex()
        let playerView = playerViews[currentPlayerIndex]
        playerViews.forEach { playerView in
            playerView.profileView.avatarImageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35).cgColor
        }
        playerView.profileView.avatarImageView.layer.borderColor = UIColor.green.cgColor
    }
    
    
    private func setUp() {
        view.backgroundImage(named: "backgrounds/background\(game.gameMode.convertToString)")
        
        game.delegate = self
        animationManager.animator = self
        
        let thisPlayerCode = game.getThisPlayerCode()
        
        switch game.gameMode {
        case .oneVsOne:
            setUpHelper(thisPlayerCode, numberOfPlayers: 2)
        case .twoVsTwo:
            setUpHelper(thisPlayerCode, numberOfPlayers: 4)
        case .ffa:
            setUpHelper(thisPlayerCode, numberOfPlayers: 4)
        }
    }
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
//        print("1:playersCodes " ,game.playerCodes)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !initialSetupDone {
            initialSetupDone = true
            let safeAreaSize = self.view.safeAreaLayoutGuide.layoutFrame.size
            layoutAppropriatelyForGameMode(size: safeAreaSize)
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard size != view.bounds.size else { return }
        invalidateOldConstraints()
        coordinator.animate { [weak self] context in
            guard let self = self else { return }
            let safeAreaSize = self.view.safeAreaLayoutGuide.layoutFrame.size
            self.layoutAppropriatelyForGameMode(size: safeAreaSize)
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    // MARK: - Datasources and Helper Functions
    
    private func transformSelectedItemsAndMovesToVisual() {
        game.selectedItems.forEach { keyValuePair in
            let collectionView = getCollectionViewFrom(playerCode: keyValuePair.key)
            selectedItems[collectionView] = keyValuePair.value
        }
        
        game.moves.forEach { keyValuePair in
            let playerAndIndexes = keyValuePair.value
            var cvAndIndexses: [UICollectionView : Int] = [:]
            playerAndIndexes.forEach { keyValuePair in
                let collectionView = getCollectionViewFrom(playerCode: keyValuePair.key)
                let index =  keyValuePair.value
                cvAndIndexses[collectionView] = index
            }
            moves[keyValuePair.key] = cvAndIndexses
        }
    }
    
    
    private func configureDataSourcesAndUpdate() {
        selectedItems.removeAll()
        moves.removeAll()
        transformSelectedItemsAndMovesToVisual()
        for i in 0 ... 2 {
            collectionViews.forEach { cv in
                let cell = cv.cellForItem(at: IndexPath(item: i, section: 0)) as? BenderCell
                cell?.backgroundColor = .systemBackground
                cv.reloadData()
            }
        }
        playerViews.forEach { $0.updateSelections(selectedItems: selectedItems, moves: moves) }
        
        for i in 0 ..< collectionViews.count {
            if game.losers.contains(game.trios[i]) {
                playerViews[i].profileView.avatarImageView.image = "😭".image()
            }
            if game.dropped.contains(game.trios[i]) {
                playerViews[i].profileView.avatarImageView.image = "🏳️".image()
            }
        }
        
        
        if game.gameFinished && !alertPresented {
            alertPresented = true
            if game.winners.count > 0 {
                timer.invalidate()
                showProperEndMessage()
            } else {
                presentAlert(title: "🏳️", message: "No one is winner here.", buttonTitle: "Ok")
            }
        }
    }
    
    
    // MARK: - Timer
    
    @objc private func fireTimer() {
//        if time == 6 {
//            game.turnSwitch = true
//        }
        time -= 1
        if time == 3 { timeLabel.textColor = game.isMyTurn ? .systemRed : .white }
//        print(game.isMyTurn)
        if time == 1 {
            if game.isMyTurn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.game.turnSwitch = false
                }
            }
        }
        if time == 0 {
            game.isMyTurn = false
            timer.invalidate()
            game.sendApproveTimeIsUp()
        }
    }
    
    
    func approveTimeIsUp() {
        if !game.attackStarted {
            game.turnSwitch = true
            guard !game.checkIfThereIsUncompletedTeammateMove() else {
                game.updateProperly()
                return
            }
            game.selectedItems.removeAll()
            game.moves.removeAll()
            game.updateProperly()
            game.state += 1
            game.attackStarted = false
        }
    }
    
    
    func resetTimer() {
        guard game.turnBased, !game.attackStarted else { return }
        timer.invalidate()
        time = 6
        showCurrentPlayer()
        if game.isMyTurn {
            soundManager.playSound()
            timeLabel.textColor = .systemGreen
        } else {
            timeLabel.textColor = .white
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - Buttons Tapped
    
    @objc private func quitButtonTapped() {
        if let nav = self.navigationController {
            game.disconnect()
            timer.invalidate()
            nav.popViewController(animated: false)
            nav.popViewController(animated: false)
        }
    }
    
    
    @objc private func soundButtonTapped() {
        soundManager.isSoundOpen.toggle()
        if soundManager.isSoundOpen {
            soundButton.updateButton(with: UIImage(systemName: "speaker.wave.2"), tintColor: .white)
        } else {
            soundButton.updateButton(with: UIImage(systemName: "speaker.slash"), tintColor: .white)
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func takeCellLocation(collectionView: UICollectionView, index: Int) -> CGPoint {
//        print("\n---takeCellLocation, \(getPlayerFromCv(collectionView: collectionView))---")
//        print(index)
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as! BenderCell
        let cellRectCenter = cell.center
        let originInRootView = collectionView.convert(cellRectCenter, to: self.view)
        
        return originInRootView
    }
    
    
    private func getPlayerCodeFrom(collectionView: UICollectionView) -> String {
        let indexOfCv = collectionViews.firstIndex { $0 == collectionView }
        return game.trios[indexOfCv!]
    }
    
    
    private func getCollectionViewFrom(playerCode: String) -> UICollectionView {
        let indexOfPlayer = game.trios.firstIndex { $0 == playerCode }
        return collectionViews[indexOfPlayer!]
    }
    
    
    private func showProperEndMessage() {
        if game.gameMode == .twoVsTwo {
            let theWinners = game.winners.map { playerCode in
                game.playersAndNicknames[playerCode]!
            }
            presentAlert(title: "🎊", message: "\(theWinners.map { $0 }.joined(separator: ", ")) are the winners", buttonTitle: "Ok")
        } else {
            let theWinner = game.playersAndNicknames[game.winners[0]]!
            presentAlert(title: "🎊", message: "\(theWinner) is the winner", buttonTitle: "Ok")
        }
        
        let winnerIndexes = game.winners.map { game.getPlayersLocalIndex(playerCode: $0)}
        winnerIndexes.forEach { playerViews[$0].profileView.avatarImageView.image = "🥳".image() }
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("GameVC is deallocated")
    }
}


// MARK: - SpoonBendersDelegate

extension GameVC: SpoonBendersDelegate {
    
    func attack(by playerCode: String, defendersTrio: String, attackerBenderIndex: Int, defenderBenderIndex: Int, duelType: DuelType) {
        prepareAnimation(by: playerCode, attackersTrio: playerCode, defendersTrio: defendersTrio, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex, duelType: duelType)
    }
    
    
    func updateProperly() {
        configureDataSourcesAndUpdate()
    }
}


// MARK: - BenderSelection

extension GameVC: BenderSelection {
    
    func didSelectBender(onPlayer: String, at: IndexPath) {
//        print("🥹didSelectBender-3")
        game.selectBender(onPlayer: onPlayer, at: at.row)
    }
}


// MARK: - Moves and Animations

extension GameVC: AnimationManagerDelegate {
    
    private func prepareAnimation(by playerCode: String, attackersTrio: String, defendersTrio: String, attackerBenderIndex: Int, defenderBenderIndex: Int, duelType: DuelType) {
        view.layoutIfNeeded()
        
        let attackersCollectionView = getCollectionViewFrom(playerCode: attackersTrio)
        let defendersCollectionView = getCollectionViewFrom(playerCode: defendersTrio)
        
        let attackerBenderPosition = takeCellLocation(collectionView: attackersCollectionView, index: attackerBenderIndex)
        let defenderBenderPosition = takeCellLocation(collectionView: defendersCollectionView, index: defenderBenderIndex)
        
        startAttackAnimation(by: playerCode, from: attackerBenderPosition, to: defenderBenderPosition, duelType: duelType)
    }
    

    private func startAttackAnimation(by player: String, from attackerPosition: CGPoint, to defenderPosition: CGPoint, duelType: DuelType) {
        let spoon = makeSpoon()
        if duelType == .firstAttack {
            animationManager.throwSpoon(by: player, from: attackerPosition, to: defenderPosition, spoon: spoon, duelType: duelType)
        } else {
            animationManager.throwSpoon(by: player, from: defenderPosition, to: attackerPosition, spoon: spoon, duelType: duelType)
        }
    }
    
    
    func startHealthDecreasingAnimation(by opponentsAttack: Int, currentlyDefendingPlayer: String, currentlyDefendingBenderIndex: Int) {
//        print("\n---startHealthDecreasingAnimation, \(defendingPlayer)---")
//        print(defenderBenderIndex)
        let currentlyDefendingPlayersCollectionView = getCollectionViewFrom(playerCode: currentlyDefendingPlayer)
        view.layoutIfNeeded()
        let defenderBenderPosition = takeCellLocation(collectionView: currentlyDefendingPlayersCollectionView, index: currentlyDefendingBenderIndex)
        let healthBubbleView = makeHealthBubbleView(withNumber: opponentsAttack)
        let deltaX: CGFloat = Int.random(in: 1..<3) == 1 ? -50 : +50
        animationManager.decreaseHealth(from: defenderBenderPosition, to: CGPoint(x: defenderBenderPosition.x + deltaX, y: defenderBenderPosition.y - 50), spoon: healthBubbleView)
    }
    
    
    private func makeSpoon() -> UIView {
        let spoon = UIImageView(image: UIImage(named: "spoons/spoon"))
        spoon.translatesAutoresizingMaskIntoConstraints = false
        spoon.backgroundColor = .clear
        view.addSubview(spoon)
        spoon.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -200).isActive = true
        spoon.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -200).isActive = true
        spoon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        spoon.widthAnchor.constraint(equalTo: spoon.heightAnchor, multiplier: 1).isActive = true
        
        return spoon
    }
    
    
    private func makeHealthBubbleView(withNumber: Int) -> UIView {
        let bubble = UIView.makeView(width: 40, height: 40, color: .clear)
        let label = CustomLabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.text = "-\(withNumber)"
        label.textColor = .red
        bubble.addSubview(label)
        label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 2).isActive = true
        label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 2).isActive = true
        label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -2).isActive = true
        label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -2).isActive = true
        view.addSubview(bubble)
        bubble.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -200).isActive = true
        bubble.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -200).isActive = true
        
        return bubble
    }
    
    
    func finishedAnimation(by player: String, duelType: DuelType) {
        game.prepareDuel(attackerPlayerCode: player, duelType: duelType)
    }
}
