//
//  LobbyVC.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 2.03.2022.
//

import UIKit
import CocoaMQTT

final class LobbyVC: UIViewController {
    
    var player: Player!
    var gameCode: String!
    var gameMode: GameMode!
    private var game: SpoonBenders!
    
    private lazy var gameLabel: CustomLabel = {
        let label = CustomLabel(textAlignment: .center)
        let str = "Game code: " + gameCode
        var mutableString = NSMutableAttributedString(string: str)
        mutableString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 11,length: 5))
        label.attributedText = mutableString
        return label
    }()
    
    private lazy var statusLabel: CustomLabel = {
        let label = CustomLabel(textAlignment: .center)
        label.text = "Waiting for players..."
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private var statusView = UIView.makeView(width: 20, height: 20, color: .clear)
    
    private lazy var statusStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [statusLabel, statusView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    private let profileHost = ProfileView(ratioOfnicknameViewToAvatar: 0.25, labelFont: UIFont(name: "Poultrygeist", size: 32))
    private let profileTwo = ProfileView(ratioOfnicknameViewToAvatar: 0.25, labelFont: UIFont(name: "Poultrygeist", size: 32))
    private let profileThree = ProfileView(ratioOfnicknameViewToAvatar: 0.25, labelFont: UIFont(name: "Poultrygeist", size: 32))
    private let profileFour = ProfileView(ratioOfnicknameViewToAvatar: 0.25, labelFont: UIFont(name: "Poultrygeist", size: 32))
    
    private lazy var profileViewCandidates = [profileHost, profileTwo, profileThree, profileFour]
    private lazy var profileViews: [ProfileView] = []
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var timer = Timer()
    
    private var initialSetupDone = false
    private lazy var joiningApproval = player.isHost
    private var goingForwards = false
    
    private var constraints: [NSLayoutConstraint] = []
    private var sizeConstraintsByTraitCollection: [NSLayoutConstraint] = []
    
    
    // MARK: - ConfigureUI
    
    private func setupConstraints() {
        constraints = [
            gameLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            gameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            gameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            gameLabel.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.size.height * 1 / 12),
            gameLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            statusStackView.topAnchor.constraint(equalToSystemSpacingBelow: gameLabel.bottomAnchor, multiplier: 2),
            statusStackView.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            statusStackView.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: view.safeAreaLayoutGuide.trailingAnchor, multiplier: 1),
            statusStackView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            statusStackView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.size.height * 1 / 12),
            statusStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ]
        
        let commonImageWidth = profileViews.first!.avatarImageView.widthAnchor
        let consistentImageWidths = profileViews.map { $0.avatarImageView.widthAnchor.constraint(equalTo: commonImageWidth) }
        constraints += consistentImageWidths
        
        let profileViewsAspectRatio = profileViews.map { $0.widthAnchor.constraint(equalTo: $0.heightAnchor) }
        profileViewsAspectRatio.forEach { $0.priority = .defaultHigh }
        constraints += profileViewsAspectRatio
    }
    
    
    private func setsizesByTraitCollection(newCollection: UITraitCollection) {
        gameLabel.font = gameLabel.font.withSize(newCollection.fontSizeBySizeClass)
        statusLabel.font = statusLabel.font.withSize(newCollection.fontSizeBySizeClass)
        
        var spacingCoefficient: CGFloat {
            // iPad Mini (6th gen) logical width(in landscape it corresponds height): 744
            if view.frame.size.height > 743 && gameMode == .oneVsOne {
                return 8
            } else {
                return 2
            }
        }
        
        profileStackView.spacing = spacingCoefficient * 8
        
        sizeConstraintsByTraitCollection = [
            profileStackView.topAnchor.constraint(equalToSystemSpacingBelow: statusStackView.bottomAnchor, multiplier: spacingCoefficient),
            profileStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: spacingCoefficient),
            profileStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8 * spacingCoefficient),
            profileStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8 * spacingCoefficient),
        ]
        
        NSLayoutConstraint.activate(sizeConstraintsByTraitCollection)
    }
    
    
    private func invalidateOldConstraints() {
        if constraints.count > 0 && constraints[0].isActive {
            NSLayoutConstraint.deactivate(constraints)
        }
    }
    
    
    private func invalidateOldConstraintsByTraitCollection() {
        NSLayoutConstraint.deactivate(sizeConstraintsByTraitCollection)
    }
    
    
    private func activateConstraints() {
        guard joiningApproval else { return }
        setupConstraints()
        NSLayoutConstraint.activate(constraints)
        if view.safeAreaLayoutGuide.layoutFrame.size.height > view.safeAreaLayoutGuide.layoutFrame.size.width {
            profileStackView.axis = .vertical
        } else {
            profileStackView.axis = .horizontal
        }
    }
    
    
    private func updateUI(playersCodes: [String], players: [String : [String]]) {
        for profile in profileViews {
            profile.avatarImageView.image = nil
            (profile.nicknameLabelOrField as! CustomLabel).text = "Waiting..."
            let indexOfProfile = profileStackView.arrangedSubviews.firstIndex { $0 == profile }!
            guard indexOfProfile < playersCodes.count else { return }
            let avatarName = players[playersCodes[indexOfProfile]]![0]
            profile.avatarImageView.image = UIImage(named: "avatars/\(avatarName)")
            (profile.nicknameLabelOrField as! CustomLabel).text = players[playersCodes[indexOfProfile]]![1]
        }
    }
    
    
    private func setup(gameMode: GameMode, playersCodes: [String], players: [String : [String]]) {
        view.subviews.first?.removeFromSuperview()
        view.backgroundImage(named: "backgrounds/background\(game.gameMode.convertToString)")
        view.addSubview(gameLabel)
        view.addSubview(statusStackView)
        view.addSubview(profileStackView)
        statusView.showImageLoadingView()
        
        let numberOfPlayers = gameMode.convertToInt
        for i in 0 ..< numberOfPlayers {
            profileViews.append(profileViewCandidates[i])
        }
        profileViews.forEach { profileStackView.addArrangedSubview($0) }
        
        updateUI(playersCodes: playersCodes, players: players)
    }
    
    
    private func approvedJoiningSettings(gameMode: GameMode, playersCodes: [String], players: [String : [String]]) {
        joiningApproval = true
        timer.invalidate()
        view.dismissImageLoadingView()
    }
    
    
    private func approveJoining() {
        game = SpoonBenders(player: player, gameCode: gameCode, gameMode: gameMode)
        game.delegate = self
        guard player.isHost else {
            view.showImageLoadingView()
            timer = Timer.scheduledTimer(
                timeInterval: 5.0,
                target: self,
                selector: #selector(fireTimer),
                userInfo: nil,
                repeats: false)
            return
        }
        setup(gameMode: gameMode, playersCodes: [player.playerCode], players: [player.playerCode: [player.playerImageName, player.playerNickname]])
    }
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundImage(named: "backgrounds/backgroundPreparation")
        approveJoining()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !initialSetupDone && joiningApproval {
            activateConstraints()
            setsizesByTraitCollection(newCollection: traitCollection)
            initialSetupDone = true
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard size != view.bounds.size else { return }
        invalidateOldConstraints()
        coordinator.animate { [weak self] context in
            guard let self = self else { return }
            self.activateConstraints()
        }
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        guard initialSetupDone else { return }
        invalidateOldConstraintsByTraitCollection()
        coordinator.animate { [weak self] _ in
            guard let self = self else { return }
            self.setsizesByTraitCollection(newCollection: newCollection)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        goingForwards = false
        title = gameMode.convertToString
        navigationController?.setNavigationBarHidden(false, animated: animated)
        let navigationBarAppearance = UINavigationBarAppearance()
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Poultrygeist", size: 17)!
        ]
        navigationBarAppearance.titleTextAttributes = attrs
        navigationBarAppearance.configureWithTransparentBackground()
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard !goingForwards else { return }
        timer.invalidate()
        if joiningApproval { game.disconnect() }
    }
    
    
    // MARK: - Leave
    
    @objc private func fireTimer() {
        view.dismissImageLoadingView()
        presentAlert(title: "Could Not Join", message: "The game is already started or your code is invalid. You can try again.", buttonTitle: "Ok")
        navigationController?.popViewController(animated: true)
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("LobbyVC is deallocated")
    }
}


// MARK: - SpoonBendersDelegate

extension LobbyVC: SpoonBendersDelegate {
    func updateWaitingPlayers() {
        if !player.isHost && !joiningApproval {
            approvedJoiningSettings(gameMode: game.gameMode, playersCodes: game.playerCodes, players: game.playersAndCharacteristics)
        }
        if !initialSetupDone {
            setup(gameMode: gameMode, playersCodes: game.playerCodes, players: game.playersAndCharacteristics)
        } else {
            updateUI(playersCodes: game.playerCodes, players: game.playersAndCharacteristics)
        }
    }
    
    
    func goForGameVc() {
        statusLabel.text = "Game is starting..."
        statusView.dismissImageLoadingView()
        
        let gameVc = GameVC(game: game, animationManager: AnimationManager(), soundManager: SoundManager())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.goingForwards = true
            self.navigationController?.pushViewController(gameVc, animated: true)
        }
    }
}
