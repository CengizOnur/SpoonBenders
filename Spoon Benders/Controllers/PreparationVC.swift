//
//  PreparationVC.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 2.03.2022.
//

import UIKit

final class PreparationVC: UIViewController {
    
    private var avatarName = "wizardBlue"
    private let avatars = ["wizardBlue", "sage", "witch", "snowman", "reaper"]
    
    private lazy var nicknameField: CustomTextField = {
        if let textField = profileView.nicknameLabelOrField as? CustomTextField {
            return textField
        } else {
            return CustomTextField()
        }
    }()
    
    private var isNicknameEntered: Bool { return !nicknameField.text!.isEmpty }
    private var isCodeEntered: Bool { return !joinTextField.text!.isEmpty }
    
    private lazy var profileView: ProfileView = {
        let profileView = ProfileView(nicknameView: .textField)
        if let textField = profileView.nicknameLabelOrField as? CustomTextField {
            textField.delegate = self
            textField.placeholder = "Nickname"
        }
        return profileView
    }()
    
    private lazy var createGameLabel: CustomLabel = {
        let label = CustomLabel(textAlignment: .center)
        label.backgroundColor = .clear
        label.text = "Create new game and invite your friends"
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    private lazy var chooseAvatarLabel: CustomLabel = {
        let label = CustomLabel(textAlignment: .center)
        label.backgroundColor = .black.withAlphaComponent(0.5)
        label.text = "Pick your avatar"
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var createGame1v1Button: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, backgroundImage: UIImage(named: "buttons/orangeButton")!, title: "1v1")
        button.addTarget(self, action: #selector(createGame(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var createGame2v2Button: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, backgroundImage: UIImage(named: "buttons/blueButton")!, title: "2v2")
        button.addTarget(self, action: #selector(createGame(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var createGameFFAButton: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, backgroundImage: UIImage(named: "buttons/redButton")!, title: "FFA")
        button.addTarget(self, action: #selector(createGame(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var joinGameLabel: CustomLabel = {
        let label = CustomLabel(textAlignment: .center)
        label.backgroundColor = .clear
        label.text = "Join your friends' game"
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 2, height: 2)
        return label
    }()
    
    private lazy var joinGameButton: CustomButton = {
        let button = CustomButton(backgroundColor: .clear, backgroundImage: UIImage(named: "buttons/greenButton")!, title: "Join")
        button.addTarget(self, action: #selector(joinGame), for: .touchUpInside)
        return button
    }()
    
    private lazy var joinTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.delegate = self
        textField.placeholder = "Code"
        return textField
    }()
    
    private lazy var profileStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileView, chooseAvatarLabel, pickerView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.setCustomSpacing(8.0, after: profileView)
        return stackView
    }()
    
    private lazy var createGameButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [createGame1v1Button, createGame2v2Button, createGameFFAButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var joinGameButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [joinGameButton, joinTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var createGameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [createGameLabel, createGameButtonStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.customize(backgroundColor: .black, radiusSize: 10, alpha: 0.5)
        return stackView
    }()
    
    private lazy var joinGameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [joinGameLabel, joinGameButtonStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.customize(backgroundColor: .black, radiusSize: 10, alpha: 0.5)
        return stackView
    }()
    
    private lazy var gameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [createGameStackView, joinGameStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .black.withAlphaComponent(0.5)
        pickerView.layer.cornerRadius = 10
        pickerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return pickerView
    }()
    
    private var initialSetupDone = false
    
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private var sizeConstraintsByTraitCollection: [NSLayoutConstraint] = []
    
    private let padding = 8.0
    
    
    // MARK: - ConfigureUI
    
    private func setupConstraints() {
        let profileStackViewConstraint = profileStackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 2/5)
        profileStackViewConstraint.priority = .required
        
        sharedConstraints = [
            profileView.widthAnchor.constraint(equalTo: profileView.heightAnchor),
            
            pickerView.widthAnchor.constraint(equalTo: profileView.widthAnchor),
            pickerView.widthAnchor.constraint(equalTo: chooseAvatarLabel.widthAnchor),
            pickerView.heightAnchor.constraint(equalTo: profileView.heightAnchor, multiplier: 0.5),
            
            chooseAvatarLabel.heightAnchor.constraint(equalTo: profileView.heightAnchor, multiplier: 0.25),
            chooseAvatarLabel.bottomAnchor.constraint(equalTo: pickerView.topAnchor),
        ]
        
        portraitConstraints = [
            profileStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: (view.safeAreaLayoutGuide.layoutFrame.size.height) * 0.05),
            profileStackView.widthAnchor.constraint(equalTo: gameStackView.widthAnchor),
            profileStackViewConstraint,
            profileStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            gameStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            gameStackView.centerXAnchor.constraint(equalTo: profileStackView.centerXAnchor),
            gameStackView.topAnchor.constraint(equalTo: profileStackView.bottomAnchor, constant: padding * 2),
            gameStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
        ]
        
        landscapeConstraints = [
            profileStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            profileStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.width / 4),
            profileStackView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8),
            profileStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            
            gameStackView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            gameStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            gameStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3),
            gameStackView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -padding * 3),
            gameStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding),
        ]
    }
    
    
    private func invalidateOldConstraints() {
        if sharedConstraints.count > 0 && sharedConstraints[0].isActive {
            NSLayoutConstraint.deactivate(sharedConstraints)
        }
        if portraitConstraints.count > 0 && portraitConstraints[0].isActive {
            NSLayoutConstraint.deactivate(portraitConstraints)
        }
        if landscapeConstraints.count > 0 && landscapeConstraints[0].isActive {
            NSLayoutConstraint.deactivate(landscapeConstraints)
        }
    }
    
    
    private func invalidateOldConstraintsByTraitCollection() {
        NSLayoutConstraint.deactivate(sizeConstraintsByTraitCollection)
    }
    
    
    private func activateConstraintsBy(newCollection: UITraitCollection) {
        [createGameLabel, chooseAvatarLabel, joinGameLabel].forEach {
            $0.font = $0.font.withSize(newCollection.fontSizeBySizeClass)
        }
        
        [createGameButtonStackView, joinGameButtonStackView].forEach {
            $0.layoutMargins = UIEdgeInsets(top: 10, left: newCollection.spaceBySizeClass, bottom: 10, right: newCollection.spaceBySizeClass)
        }
        
        sizeConstraintsByTraitCollection = [
            joinTextField.heightAnchor.constraint(equalToConstant: 8 * newCollection.constantBySizeClass),
            createGame1v1Button.heightAnchor.constraint(equalToConstant: 8 * newCollection.constantBySizeClass),
            nicknameField.heightAnchor.constraint(equalToConstant: 8 * newCollection.constantBySizeClass),
        ]
        
        NSLayoutConstraint.activate(sizeConstraintsByTraitCollection)
    }
    
    
    private func activateConstraints() {
        setupConstraints()
        NSLayoutConstraint.activate(sharedConstraints)
        if view.safeAreaLayoutGuide.layoutFrame.size.height > view.safeAreaLayoutGuide.layoutFrame.size.width {
            NSLayoutConstraint.activate(portraitConstraints)
        } else {
            NSLayoutConstraint.activate(landscapeConstraints)
        }
    }
    
    
    private func setup() {
        view.addSubview(profileStackView)
        view.addSubview(gameStackView)
        view.backgroundImage(named: "backgrounds/backgroundPreparation")
        profileView.avatarImageView.image = UIImage(named: "avatars/\(avatarName)")
        view.backgroundColor = .systemBackground
        
        // keyboard
        hideKeyboardWhenTappedAround()
    }
    
    
    // MARK: - Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !initialSetupDone {
            activateConstraints()
            activateConstraintsBy(newCollection: traitCollection)
            initialSetupDone = true
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard size != view.bounds.size else { return }
        invalidateOldConstraints()
        coordinator.animate { [weak self] _ in
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
            self.activateConstraintsBy(newCollection: newCollection)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if initialSetupDone {
            invalidateOldConstraints()
            activateConstraints()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - Go to LobbyVC
    
    @objc private func createGame(_ sender: Any) {
        guard isNicknameEntered else {
            presentAlert(title: "Missing Nickname", message: "You need a nickname", buttonTitle: "Ok")
            return
        }
        let textOnButton: String = ((sender as! CustomButton).titleLabel?.text)!
        let lobbyVC = LobbyVC()
        let player = Player(playerNickname: nicknameField.text!, playerImageName: avatarName, playerCode: Int.randomCode, isHost: true)
        lobbyVC.player = player
        lobbyVC.gameCode = "\(nicknameField.text!.first!)" + "\(Int.randomCode)" + "\(textOnButton.last!)"
        lobbyVC.gameMode = textOnButton.convertToGameMode
        dismissKeyboard()
        navigationController?.pushViewController(lobbyVC, animated: true)
    }
    
    
    @objc private func joinGame() {
        guard isCodeEntered && isNicknameEntered else {
            if !isNicknameEntered {
                presentAlert(title: "Missing Nickname", message: "You need nickname", buttonTitle: "Ok")
            } else {
                presentAlert(title: "Missing Code", message: "Enter invitation code to join a game", buttonTitle: "Ok")
            }
            return
        }
        let lobbyVC = LobbyVC()
        let player = Player(playerNickname: nicknameField.text!, playerImageName: avatarName, playerCode: Int.randomCode)
        lobbyVC.player = player
        let gameCode = joinTextField.text!
        lobbyVC.gameCode = gameCode
        lobbyVC.gameMode = String(gameCode.last!).convertToGameMode
        dismissKeyboard()
        navigationController?.pushViewController(lobbyVC, animated: true)
    }
}


// MARK: - UITextFieldDelegate

extension PreparationVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        joinGame()
        return true
    }
}


// MARK: - UIPicker

extension PreparationVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return avatars.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let avatarName = avatars[row]
        let image = UIImage(named: "avatars/\(avatarName)")
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        return imageView
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        avatarName = avatars[row]
        let image = UIImage(named: "avatars/\(avatarName)")
        profileView.avatarImageView.image = image
    }
}


// MARK: - Keyboard

extension PreparationVC {
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField else { return }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        // if searchFields bottom is beneath keyboards bottom, frame goes up
        if textFieldBottomY > keyboardTopY {
            let preNewFrameY = -(textFieldBottomY - keyboardTopY) - 24
            if #available(iOS 11.0, *) {
                calculateWithSafeBottom(bottom: view.safeAreaInsets.bottom, preNewFrameY: preNewFrameY)
            } else {
                calculateWithSafeBottom(bottom: bottomLayoutGuide.length, preNewFrameY: preNewFrameY)
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    func calculateWithSafeBottom(bottom: CGFloat, preNewFrameY: CGFloat) {
        if bottom > 0 {
            let newFrameY = preNewFrameY - bottom / 2
            view.frame.origin.y = newFrameY
        } else {
            view.frame.origin.y = preNewFrameY
        }
    }
}


// MARK: - SwiftUI Preview

// #if DEBUG
// import SwiftUI
//
// struct PreparationVC_Previews: PreviewProvider {
//     static var previews: some View {
//         ViewControllerPreview<PreparationVC>()
//     }
// }
// #endif
