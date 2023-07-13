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
    
    private lazy var leaveButton: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, title: nil, image: UIImage(named: "buttons/leaveButton"), imageSize: 24)
        button.addTarget(self, action: #selector(leaveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var soundButton: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, title: nil, image: UIImage(named: "buttons/soundOnButton"), imageSize: 24)
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
    
    private var initialSetupDone = false
    private var alertPresented = false
    
    private let verticalInset: CGFloat = 4
    private let horizontalInset: CGFloat = 4

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: - ConfigureUI
    
    // Layouts OneVSOne
    private func layoutPortraitOneVsOne(size: CGSize) {
        let coefficient = traitCollection.coefficientOfPlayerView(orientation: .portrait)
        let constant = floor(size.width / 11) * coefficient * 8
        
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
            playerViews[0].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                        
            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            playerViews[1].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ]
    }
    
    
    private func layoutLandscapeOneVsOne(size: CGSize) {
        let coefficient = traitCollection.coefficientOfPlayerView(orientation: .landscape)
        let constant = floor(size.height / 11) * coefficient * 6
        
        let playerViewOneWidth = floor(constant * 2.5)
        let playerViewOneHeight = floor(constant * 6)
        
        let playerViewTwoWidth = floor(constant * 2.5)
        let playerViewTwoHeight = floor(constant * 6)
        
        playerViewsSizes[0].width = playerViewOneWidth
        playerViewsSizes[0].height = playerViewOneHeight
        
        playerViewsSizes[1].width = playerViewTwoWidth
        playerViewsSizes[1].height = playerViewTwoHeight
        
        // Set subviews sizes
        landscapeConstraints = [
            playerViews[0].widthAnchor.constraint(equalToConstant: playerViewOneWidth),
            playerViews[0].heightAnchor.constraint(equalToConstant: playerViewOneHeight),
            playerViews[0].leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 4),
            playerViews[0].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            playerViews[1].widthAnchor.constraint(equalToConstant: playerViewTwoWidth),
            playerViews[1].heightAnchor.constraint(equalToConstant: playerViewTwoHeight),
            playerViews[1].trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            playerViews[1].centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ]
    }
    
    
    // Layouts TwoVSTwo
    private func layoutPortraitTwoVsTwo(size: CGSize) {
        let coefficient = traitCollection.coefficientOfPlayerView(orientation: .portrait)
        let constant = floor(size.width / 11) * coefficient * 6
        
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
        let coefficient = traitCollection.coefficientOfPlayerView(orientation: .landscape)
        let constant = floor(size.height / 11 / 3) * coefficient * 5
        
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
        let coefficient = traitCollection.coefficientOfPlayerView(orientation: .portrait)
        let constant = floor(size.width / 11) * coefficient * 6
        
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
        let coefficient = traitCollection.coefficientOfPlayerView(orientation: .landscape)
        let constant = floor(size.height / 11) * coefficient * 4.25
        
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
        RunLoop.current.add(timer, forMode: .common)
        
        view.addSubview(timeLabel)
        
        timeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        timeLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 32).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: timeLabel.widthAnchor).isActive = true
        timeLabel.layer.cornerRadius = 16
        timeLabel.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
    
    
    private func configureSettingsButton() {
        view.addSubview(leaveButton)
        
        leaveButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1).isActive = true
        leaveButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1).isActive = true
        leaveButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        leaveButton.heightAnchor.constraint(equalTo: leaveButton.widthAnchor).isActive = true
        leaveButton.layer.cornerRadius = 16
    }
    
    
    private func configureSoundButton() {
        view.addSubview(soundButton)
        
        soundButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1).isActive = true
        soundButton.topAnchor.constraint(equalToSystemSpacingBelow: leaveButton.bottomAnchor, multiplier: 1).isActive = true
        soundButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        soundButton.heightAnchor.constraint(equalTo: soundButton.widthAnchor).isActive = true
        soundButton.layer.cornerRadius = 16
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
            let positions: [Position] = [.leftOrTop, .rightOrBottom]
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
    
    
    private func setUpHelper(_ playerOneCode: String) {
        let numberOfPlayers = game.gameMode.convertToInt
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
            if game.isMyTurn { play(sound: .turn) }
        }
    }
    
    
    private func showCurrentPlayer() {
        let currentPlayerIndex = game.getCurrentPlayersLocalIndex()
        let playerView = playerViews[currentPlayerIndex]
        playerViews.forEach { playerView in
            playerView.profileView.avatarImageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        }
        playerView.profileView.avatarImageView.layer.borderColor = UIColor.green.cgColor
    }
    
    
    private func setUp() {
        view.backgroundImage(named: "backgrounds/background\(game.gameMode.convertToString)")
        
        game.delegate = self
        animationManager.animator = self
        
        let thisPlayerCode = game.getThisPlayerCode()
        setUpHelper(thisPlayerCode)
    }
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
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
        collectionViews.forEach { $0.collectionViewLayout.invalidateLayout() }
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
        time -= 1
        if time == 3 { timeLabel.textColor = game.isMyTurn ? .systemRed : .white }
        if time == 1 {
            if game.isMyTurn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.game.turnSwitch = false
                }
            }
        }
        if time == 0 {
            timer.invalidate()
            self.game.isMyTurn = false
            self.game.sendApproveTimeIsUp()
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
        game.turnSwitch = true
        time = 6
        showCurrentPlayer()
        if game.isMyTurn {
            play(sound: .turn)
            timeLabel.textColor = .systemGreen
        } else {
            timeLabel.textColor = .white
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    
    // MARK: - Buttons Tapped
    
    @objc private func leaveButtonTapped() {
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
            soundButton.updateButton(with: UIImage(named: "buttons/soundOnButton"), tintColor: .white)
        } else {
            soundButton.updateButton(with: UIImage(named: "buttons/soundOffButton"), tintColor: .white)
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func takeCellLocation(collectionView: UICollectionView, index: Int) -> CGPoint {
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
    
    
    func getPlayerView(collectionView: UICollectionView) -> PlayerView {
        let playerView = playerViews.filter { $0.collectionView === collectionView }.first!
        return playerView
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
    
    
    func play(sound: SoundType) {
        soundManager.play(sound)
    }
}


// MARK: - BenderSelection

extension GameVC: BenderSelection {
    
    func didSelectBender(onPlayer: String, at: IndexPath) {
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
        
        let currentlyAttackingTrio = duelType == .firstAttack ? attackersTrio : defendersTrio
        let currentlyAttackingPlayerIndex = game.getPlayersLocalIndex(playerCode: currentlyAttackingTrio)
        let currentlyAttackingBenderIndex = duelType == .firstAttack ? attackerBenderIndex : defenderBenderIndex
        let throwableObjectConstant = game.benderNumbers[currentlyAttackingPlayerIndex][currentlyAttackingBenderIndex]
        
        let currentlyAttackingCollectionView = duelType == .firstAttack ? attackersCollectionView : defendersCollectionView
        let benderPosition = getPlayerView(collectionView: currentlyAttackingCollectionView).bendersPosition
        
        startAttackAnimation(by: playerCode, from: attackerBenderPosition, to: defenderBenderPosition, duelType: duelType, throwableObjectConstant: throwableObjectConstant, throwingFrom: benderPosition)
    }
    

    private func startAttackAnimation(by player: String, from attackerPosition: CGPoint, to defenderPosition: CGPoint, duelType: DuelType, throwableObjectConstant: Int, throwingFrom: BenderPosition) {
        let throwableObject = makeThrowableObject(throwableObjectConstant: throwableObjectConstant, throwingFrom: throwingFrom)
        if duelType == .firstAttack {
            animationManager.throwObject(by: player, from: attackerPosition, to: defenderPosition, throwableObject: throwableObject, duelType: duelType)
        } else {
            animationManager.throwObject(by: player, from: defenderPosition, to: attackerPosition, throwableObject: throwableObject, duelType: duelType)
        }
    }
    
    
    func startHealthDecreasingAnimation(by opponentsAttack: Int, currentlyDefendingPlayer: String, currentlyDefendingBenderIndex: Int) {
        let currentlyDefendingPlayersCollectionView = getCollectionViewFrom(playerCode: currentlyDefendingPlayer)
        view.layoutIfNeeded()
        let defenderBenderPosition = takeCellLocation(collectionView: currentlyDefendingPlayersCollectionView, index: currentlyDefendingBenderIndex)
        let healthBubbleView = makeHealthBubbleView(withNumber: opponentsAttack)
        let deltaX: CGFloat = Int.random(in: 1..<3) == 1 ? -50 : +50
        animationManager.decreaseHealth(from: defenderBenderPosition, to: CGPoint(x: defenderBenderPosition.x + deltaX, y: defenderBenderPosition.y - 50), throwableObject: healthBubbleView)
    }
    
    
    private func makeThrowableObject(throwableObjectConstant: Int, throwingFrom: BenderPosition) -> UIView {
        
        /// Instead of using random numbers for a move,
        /// it is using arbitrary numbers for a game depends on current bender index and benders which already are created by random numbers
        let throwableObjectTypeNumber = (game.benderNumbers.flatMap { $0 }.reduce(0, +) + throwableObjectConstant) % 3
        
        let throwableObjectType = throwableObjectTypeNumber.throwableObjectType
        let throwingSide: BenderPosition? = throwableObjectType == .bat ? throwingFrom : nil
        let extraSize: CGFloat = throwableObjectType == .bat ? 8 : 0
        
        let throwableObjectImageView = UIImageView()
        throwableObjectImageView.stopAnimating()
        throwableObjectImageView.animationImages = animatedImages(for: throwableObjectType, throwingFrom: throwingSide)
        throwableObjectImageView.animationDuration = 1.1
        throwableObjectImageView.animationRepeatCount = 0
        throwableObjectImageView.image = throwableObjectImageView.animationImages?.first
        throwableObjectImageView.startAnimating()
        throwableObjectImageView.translatesAutoresizingMaskIntoConstraints = false
        throwableObjectImageView.backgroundColor = .clear
        
        view.addSubview(throwableObjectImageView)
        throwableObjectImageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -200).isActive = true
        throwableObjectImageView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -200).isActive = true
        throwableObjectImageView.heightAnchor.constraint(equalToConstant: traitCollection.fontSizeBySizeClass + 16 + extraSize).isActive = true
        throwableObjectImageView.widthAnchor.constraint(equalTo: throwableObjectImageView.heightAnchor, multiplier: 1).isActive = true
        
        return throwableObjectImageView
    }
    
    
    func animatedImages(for throwableObjectType: ThrowableObjectType, throwingFrom: BenderPosition? = nil) -> [UIImage] {
        var images = [UIImage]()
        let imageName = "throwableObjects/\(throwableObjectType)"
        let benderSide = throwingFrom != nil ? "\(throwingFrom!)".firstUppercased : ""
        var i = 1
        while let image = UIImage(named: "\(imageName)\(benderSide)\(i)") {
            images.append(image)
            i += 1
        }
        return images
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
