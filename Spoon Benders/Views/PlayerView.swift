//
//  PlayerView.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 9.12.2022.
//

import Foundation
import UIKit

protocol BenderSelection: AnyObject {
    
    func didSelectBender(onPlayer: String, at: IndexPath)
}


/// For setting  the order of items properly in the stackview.
enum Position {
    case leftOrTop
    case rightOrBottom
}


enum BenderPosition: String {
    case left
    case right
}


final class PlayerView: UIView {
    
    private var playerCode = "0"
    var collectionViewOwnerPlayerCode = "0"
    var benders = [Bender]()
    
    weak var delegate: BenderSelection?
    
    init(playerCode: String, collectionViewOwnerPlayerCode: String, avatarImage: UIImage, nickname: String, benders: [Bender]) {
        super.init(frame: .zero)
        self.playerCode = playerCode
        self.collectionViewOwnerPlayerCode = collectionViewOwnerPlayerCode
        self.profileView.avatarImageView.image = avatarImage
        (self.profileView.nicknameLabelOrField as! CustomLabel).text = nickname
        self.benders = benders
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selectedItems: [UICollectionView : [Int]] = [:]
    private var moves: [String : [UICollectionView : Int]] = [:]
    
    let profileView = ProfileView(nicknameView: .label, ratioOfnicknameViewToAvatar: 1/3)
    
    private let verticalInset: CGFloat = 4
    private let horizontalInset: CGFloat = 4
    private var itemHeight = 0.0
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BenderCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 4
        flowLayout.minimumInteritemSpacing = 4
        flowLayout.sectionInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset)
        return flowLayout
    }()
    
    private let cellIdentifier = BenderCell.reuseID
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileView, collectionView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private var selfSize = CGSize(width: 0, height: 0)
    private var position: Position = .leftOrTop
    var bendersPosition: BenderPosition = .right
    
    private var profileViewWidth = 0.0
    private var profileViewHeight = 0.0
    private var collectionViewWidth = 0.0
    private var collectionViewHeight = 0.0
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: - ConfigureUI
    
    func updateLayout(size: CGSize, position: Position) {
        selfSize = size
        self.position = position
    }
    
    
    func updateSelections(selectedItems: [UICollectionView : [Int]], moves: [String : [UICollectionView : Int]]) {
        self.selectedItems = selectedItems
        self.moves = moves
    }
    
    
    private func portraitFlowLayouts(flowLayout: UICollectionViewFlowLayout, relatedCollectionViewWidth: CGFloat, relatedCollectionViewHeight: CGFloat) {
        let availableWidth = relatedCollectionViewWidth - 2 * horizontalInset
        let availableHeight = relatedCollectionViewHeight - 2 * flowLayout.minimumLineSpacing - 2 * verticalInset
        guard availableWidth > 0 && availableHeight > 0 else { return }
        let width = floor(availableWidth)
        itemHeight = floor(availableHeight / 3)
        let itemSize = CGSize(width: width, height: itemHeight)
        flowLayout.itemSize = itemSize
    }
    
    
    private func landscapeFlowLayouts(flowLayout: UICollectionViewFlowLayout, relatedCollectionViewWidth: CGFloat, relatedCollectionViewHeight: CGFloat) {
        let availableWidth = relatedCollectionViewWidth - 2 * horizontalInset - 2 * flowLayout.minimumInteritemSpacing
        let availableHeight = relatedCollectionViewHeight - 2 * verticalInset
        guard availableWidth > 0 && availableHeight > 0 else { return }
        let width = floor(availableWidth / 3)
        itemHeight = floor(availableHeight)
        let itemSize = CGSize(width: width, height: itemHeight)
        flowLayout.itemSize = itemSize
    }
    
    
    private func layoutPortrait(size: CGSize, position: Position) {
        profileViewWidth = size.width / 2.5
        profileViewHeight = floor(profileViewWidth * 4 / 3 + 15)
        collectionViewWidth = floor(profileViewWidth * 1.5)
        collectionViewHeight = floor(profileViewWidth * 2 * 3)
        
        stackView.axis = .horizontal
        profileView.fontSize = profileViewHeight / 4 - 2
        
        if position == .leftOrTop {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            [profileView, collectionView].forEach { stackView.addArrangedSubview($0) }
        } else {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            [collectionView, profileView].forEach { stackView.addArrangedSubview($0) }
        }
        
        portraitConstraints = [
            profileView.widthAnchor.constraint(equalToConstant: profileViewWidth),
            profileView.heightAnchor.constraint(equalToConstant: profileViewHeight),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
    }
    
    
    private func layoutLandscape(size: CGSize, position: Position) {
        profileViewWidth = (size.height - 15) / 10 * 3
        profileViewHeight = floor(profileViewWidth * 4 / 3 + 15)
        collectionViewWidth = floor(profileViewWidth * 1.5 * 3)
        collectionViewHeight = floor(profileViewWidth * 2)
        
        stackView.axis = .vertical
        profileView.fontSize = profileViewHeight / 4 - 2
        
        if position == .leftOrTop {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            [profileView, collectionView].forEach { stackView.addArrangedSubview($0) }
        } else {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            [collectionView, profileView].forEach { stackView.addArrangedSubview($0) }
        }
        
        landscapeConstraints = [
            profileView.widthAnchor.constraint(equalToConstant: profileViewWidth),
            profileView.heightAnchor.constraint(equalToConstant: profileViewHeight),
            
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
    }
    
    
    private func invalidateOldConstraints() {
        if portraitConstraints.count > 0 && portraitConstraints[0].isActive {
            NSLayoutConstraint.deactivate(portraitConstraints)
        }
        if landscapeConstraints.count > 0 && landscapeConstraints[0].isActive {
            NSLayoutConstraint.deactivate(landscapeConstraints)
        }
    }
    
    
    private func configureLayout(size: CGSize, position: Position) {
        if size.height > size.width {
            guard frame.width == size.width else { return }
            layoutPortrait(size: size, position: position)
            NSLayoutConstraint.activate(portraitConstraints)
            portraitFlowLayouts(flowLayout: flowLayout, relatedCollectionViewWidth: collectionViewWidth, relatedCollectionViewHeight: collectionViewHeight)
        } else {
            guard frame.width == size.width  else { return }
            layoutLandscape(size: size, position: position)
            NSLayoutConstraint.activate(landscapeConstraints)
            landscapeFlowLayouts(flowLayout: flowLayout, relatedCollectionViewWidth: collectionViewWidth, relatedCollectionViewHeight: collectionViewHeight)
        }
        collectionView.reloadData()
    }
    
    
    private func setUp() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    
    // MARK: - Lifecycle Functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateOldConstraints()
        configureLayout(size: selfSize, position: position)
    }
    
    
    // Deinit For Testing Purposes
    deinit {
//        print("PlayerView is deallocated")
    }
}


// MARK: - UICollectionViewDataSource

extension PlayerView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return benders.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BenderCell.reuseID, for: indexPath) as! BenderCell
        
        cell.backgroundColor = .clear
        cell.benderImageView.layer.borderColor = UIColor.clear.cgColor
        
        // Before, all selected benders should be red
        if let items = selectedItems[collectionView] {
            if items.contains(indexPath.row) {
                cell.benderImageView.layer.borderColor = UIColor.red.cgColor
            }
        }
        
        // Selected bender by this player should be green, the other selected benders will be red
        if moves.keys.contains(playerCode) {
            let movesByThisPlayer = moves[playerCode]!
            if let elementSelectedByThisPlayer = movesByThisPlayer[collectionView] {
                if elementSelectedByThisPlayer == indexPath.row {
                    cell.benderImageView.layer.borderColor = UIColor.green.cgColor
                }
            }
        }
        
        cell.setAndUpdateBenderOnCell(bender: benders[indexPath.row], benderPosition: bendersPosition)
        
        return cell
    }
}


// MARK: - UICollectionViewDelegate

extension PlayerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectBender(onPlayer: collectionViewOwnerPlayerCode, at: indexPath)
    }
}
