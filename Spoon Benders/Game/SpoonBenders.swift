//
//  SpoonBenders.swift
//  Spoon Benders
//
//  Created by Onur Akdogan on 25.02.2022.
//

import Foundation

protocol SpoonBendersDelegate: AnyObject {
    
    /// Lobby Functions
    func updateWaitingPlayers()
    func goForGameVc()
    
    /// In Game Functions
    func play(sound: SoundType)
    func attack(by playerCode: String, defendersTrio: String, attackerBenderIndex: Int, defenderBenderIndex: Int, duelType: DuelType)
    func updateProperly()
    func resetTimer()
    func approveTimeIsUp()
    func startHealthDecreasingAnimation(by opponentsAttack: Int, currentlyDefendingPlayer: String, currentlyDefendingBenderIndex: Int)
}


extension SpoonBendersDelegate {
    
    func updateWaitingPlayers() { }
    func goForGameVc() { }
    
    func play(sound: SoundType) { }
    func attack(by playerCode: String, defendersTrio: String, attackerBenderIndex: Int, defenderBenderIndex: Int, duelType: DuelType) { }
    func updateProperly() { }
    func resetTimer() { }
    func approveTimeIsUp() { }
    func startHealthDecreasingAnimation(by opponentsAttack: Int, currentlyDefendingPlayer: String, currentlyDefendingBenderIndex: Int) { }
}


final class SpoonBenders {
    
    lazy var gameCommunication: GameCommunication = GameCommunication(player: player, gameCode: gameCode, gameMode: gameMode)
    
    var player: Player!
    var gameCode: String!
    var gameMode: GameMode
    
    init(player: Player, gameCode: String, gameMode: GameMode) {
        self.player = player
        self.gameMode = gameMode
        self.gameCode = gameCode
        gameCommunication.delegate = self
    }
    
    weak var delegate: SpoonBendersDelegate?
    
    lazy var mode: PlayMode = gameMode == .twoVsTwo ? .teamplay : .individual
    lazy var turnBased: Bool = gameMode == .ffa ? false : true
    lazy var turnSwitch = true
    var isMyTurn: Bool {
        get {
            guard turnBased else { return true }
            guard !attackStarted, !losers.contains(getCurrentPlayersCode()) else { return false }
            return state % numberOfPlayers == getThisPlayersGlobalIndex()
        } set { }
    }
    
    var playersAndCharacteristics: [String : [String]] = [:]
    var playersAndBenders: [String : [Int]] = [:]
    
    var playerCodes: [String] = []
    var playersAndAvatars: [String : String] = [:]
    var playersAndNicknames: [String : String] = [:]
    
    var trios: [String] = []
    var benderNumbers: [[Int]] = []
    private(set) var benders = [[Bender]]()
    
    var numberOfPlayers: Int {
        return playerCodes.count
    }
    
    var selectedItems: [String : [Int]] = [:]
    var moves: [String : [String : Int]] = [:]
    var waitingMoves: [String : [String : Int]] = [:]
    var teammates: [String : String] = [:]
    
    var losers: Set<String> = []
    var dropped: Set<String> = []
    var winners: [String] = []
    var gameFinished = false
    
    var state = 0
    
    var attackStarted: Bool = false {
        didSet {
            guard !gameFinished, turnBased, !attackStarted else { return }
            while losers.contains(getCurrentPlayersCode()) { state += 1 }
            delegate?.resetTimer()
        }
    }
    
    
    // MARK: - Create Benders
    
    func createBenders(randomNumbers: [Int], which: Int) {
        for number in randomNumbers {
            let bender = assignBender(by: number, mode: mode)
            benders.append([])
            benders[which].append(bender)
        }
    }
    
    
    // MARK: - Make a Move
    
    func selectBender(onPlayer: String, at index: Int) {
        guard turnSwitch, !gameFinished, isMyTurn, !losers.contains(onPlayer) else { return }
        
        if gameMode == .twoVsTwo,
           attackStarted { return }
        
        /// Check if there is no right to select more bender
        if let movesByPlayer = moves[trios[0]], movesByPlayer.count >= 2 { return }
        
        /// If game is 2v2 and this player is trying to select teammates bender (trios[0] => this player,  trios[1] => teammate)
        if gameMode == .twoVsTwo,
            onPlayer == trios[1] {
            delegate?.play(sound: .notSelected)
            return
        }
        
        /// Index of player to make a move on it (It can be any player including itself)
        let indexOfPlayer = getPlayersLocalIndex(playerCode: onPlayer)
        
        /// If current player is trying to select bender that gave up already
        guard benders[indexOfPlayer][index].state != .gaveUp else {
            delegate?.play(sound: .notSelected)
            return
        }
        
        /// If bender is already selected
        if let items = selectedItems[onPlayer] {
            if items.contains(index) {
                return
            }
        }
        
        delegate?.play(sound: .select)
        
        let thisPlayersMove = "MoveState:\(gameCommunication.moveState)=>MoveBy:\(trios[0])-MoveOn:\(onPlayer)-WhichBender:\(index)"
        
        /// MQTT - publish message
        /// MoveBy:165-MoveOn:183-WhichBender:2
        gameCommunication.publishMessage(message: thisPlayersMove)
    }
    
    
    func makeAMove(playerCode: String, trio: String, index: Int) {
        /// moves => [String : [String : Int]]
        /// playerCode : [trio : index]
        /// trio corresponds collectionView(cv) in ViewController
        /// Ex: "165" (current player who made this move) => cv1, "183" (opponent of current player) => cv2
        /// "165" : ["183" : 2, "165" : 0]
        
        /// If the player has not played yet =>  "165" : [...?] It doesn't exist
        /// "165" : [:]
        /// "165" : [cv2 : 2]
        guard let movesByPlayer = moves[playerCode] else {
            checkAndUpdateSelectedItems(trio: trio, index: index)
            moves[playerCode] = [:]
            moves[playerCode]![trio] = index
            updateProperly()
            return
        }
        
        /// movesByPlayer can not have more than 1 elements. If it is 2, there will be attack and then it will reset.
        /// trio => "183" (corresponds cv2)
        let cvSelectedBefore = movesByPlayer.first!.key
        
        /// index => 2
        let indexSelectedBefore = movesByPlayer.first!.value

        arrangeSelections(playerCode: playerCode, trio: trio, index: index, trioSelectedBefore: cvSelectedBefore, indexSelectedBefore: indexSelectedBefore)
        
        if let movesByPlayer = moves[playerCode],
           movesByPlayer.count == 2 {
            takeAction(playerCode: playerCode, movesByPlayer: movesByPlayer)
        }
    }
    
    
    func arrangeSelections(playerCode: String, trio: String, index: Int, trioSelectedBefore: String, indexSelectedBefore: Int) {
        /// Ex: cv1 belongs to current player who made this move
        /// cv2 and cv3 are not belong to current player and that player decide to change item to attack on it.     cv3 : 1 -> cv2 : 2
        if trioSelectedBefore != playerCode && trio != playerCode {
            
            /// selectedItems => [String : [Int]]
            /// trio : [Int, Int]
            /// Ex: cv3 : [0, 1, 2] -> cv3 : [0, 2] (0 and 2 in cv3 are selected by other players and their colors are red)
            selectedItems[trioSelectedBefore] = selectedItems[trioSelectedBefore]!.filter { $0 != indexSelectedBefore }
            checkAndUpdateSelectedItems(trio: trio, index: index)
            
            /// "165" : ["127" : 1] -> "165" : ["183" : 2]  ("165" corresponds cv1, "127" corresponds cv3 and "183" corresponds cv2)
            moves[playerCode]![trioSelectedBefore] = nil
            moves[playerCode]![trio] = index
            
        /// cv1 is belongs to current player and that player decide to change item as that players own bender.      cv1 : 2 -> cv1 : 0
        } else if trioSelectedBefore == playerCode && trio == playerCode {
            
            /// cv1 : [1, 2] -> cv1 : [1] (1 is selected by someone else)
            selectedItems[trioSelectedBefore] = selectedItems[trioSelectedBefore]!.filter { $0 != indexSelectedBefore }
            checkAndUpdateSelectedItems(trio: trio, index: index)
            
            /// "165" : ["165" : 2] -> "165" : ["165" : 0]
            moves[playerCode]![trioSelectedBefore] = nil
            moves[playerCode]![trio] = index
            
        /// cv1 is belongs to current player, cv2 belongs to opponent and current player decide to attack on it.      cv1 : 0, cv2 : 2 (Bender at index 0 on cv1 will attack bender at index 2 on cv2)
        } else {
            checkAndUpdateSelectedItems(trio: trio, index: index)
            
            /// "165" : ["165" : 0, "183" : 2]
            moves[playerCode]![trio] = index
        }
        updateProperly()
    }
    
    
    func checkAndUpdateSelectedItems(trio: String, index: Int) {
        /// selectedItems => [String : [Int]]
        /// trio : [Int, Int]
        
        /// "183" : [0, 1] -> "183" : [0, 1, 2]
        if selectedItems[trio] != nil {
            selectedItems[trio]!.append(index)
            
        /// "183" : [] -> "183" : [2]
        } else {
            selectedItems[trio] = []
            selectedItems[trio]!.append(index)
        }
    }
    
    
    func takeAction(playerCode: String, movesByPlayer: [String : Int]) {
        if gameMode == .twoVsTwo {
            waitingMoves[playerCode] = movesByPlayer
            if isFirstPlayerInTeam(playerCode: playerCode) {
                state += 1
                attackStarted = false
            } else {
                for playerCode in waitingMoves.keys {
                    if let movesByPlayer = moves[playerCode] {
                        attack(playerCode: playerCode, movesByPlayer: movesByPlayer, duelType: .firstAttack)
                    }
                }
                state += 1
            }
        } else {
            state += 1
            attack(playerCode: playerCode, movesByPlayer: movesByPlayer, duelType: .firstAttack)
        }
    }
    
    
    func attack(playerCode: String, movesByPlayer: [String : Int], duelType: DuelType) {
        guard !gameFinished else { return }
        attackStarted = true
        
        let attackerBenderIndex = movesByPlayer[playerCode]!
        let defendersTrio = movesByPlayer.keys.filter{ $0 != playerCode }.first!
        let defenderBenderIndex = movesByPlayer[defendersTrio]!
        
        var attackerBender = getBender(playerCode: playerCode, benderIndex: attackerBenderIndex)
        var defenderBender = getBender(playerCode: defendersTrio, benderIndex: defenderBenderIndex)
        
        setBenderStates(when: "beforeAttackAnimation", attackerBender: &attackerBender, defenderBender: &defenderBender, duelType: duelType)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.play(sound: .attack)
            self.delegate?.attack(by: playerCode, defendersTrio: defendersTrio, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex, duelType: duelType)
        }
    }
    
    
    // MARK: - Duel
    
    func prepareDuel(attackerPlayerCode: String, duelType: DuelType) {
        guard !gameFinished else { return }
        guard let movesByPlayer = moves[attackerPlayerCode] else { return }
        
        let keys = [String](movesByPlayer.keys)
        let defenderPlayerCode = keys.filter { $0 != attackerPlayerCode }.first!
        
        let attackerPlayerIndex = getPlayersLocalIndex(playerCode: attackerPlayerCode)
        let attackerBenderIndex = movesByPlayer[attackerPlayerCode]!
        
        let defenderPlayerIndex = getPlayersLocalIndex(playerCode: defenderPlayerCode)
        let defenderBenderIndex = movesByPlayer[defenderPlayerCode]!
        
        var attackerBender = benders[attackerPlayerIndex][attackerBenderIndex]
        var defenderBender = benders[defenderPlayerIndex][defenderBenderIndex]
        
        var teammateBender: Bender? {
            getTeammateBender(attackerPlayerCode: attackerPlayerCode)
        }
        
        setBenderStates(when: "afterAttackAnimation", attackerBender: &attackerBender, defenderBender: &defenderBender, duelType: duelType)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.makeDuel(movesByPlayer: movesByPlayer, attackerPlayerCode: attackerPlayerCode, defenderPlayerCode: defenderPlayerCode, attackerBender: attackerBender, defenderBender: defenderBender, teammateBender: teammateBender, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex, duelType: duelType)
        }
    }
    
    
    func makeDuel(movesByPlayer: [String : Int], attackerPlayerCode: String, defenderPlayerCode: String, attackerBender: Bender, defenderBender: Bender, teammateBender: Bender?, attackerBenderIndex: Int, defenderBenderIndex: Int, duelType: DuelType) {
        guard !gameFinished else { return }
        if duelType == .firstAttack {
            duel(currentlyDefendingPlayerTrio: defenderPlayerCode, currentlyDefendingBenderIndex: defenderBenderIndex, currentlyAttackingBender: attackerBender, currentlyDefendingBender: defenderBender, currentlyAttackingBendersTeammateBender: teammateBender)
            updateProperly()

            /// Check if defender bender gave up
            if defenderBender.health == 0 {
                waitingMoves[attackerPlayerCode] = nil
                updateAfterAttack(attackerPlayer: attackerPlayerCode, defenderPlayer: defenderPlayerCode, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex)
                
                /// After first attack, if duel is finished and If there is teammates waiting move, it should wait for it.
                if gameMode == .twoVsTwo, waitingMoves[teammates[attackerPlayerCode]!] != nil { return }
                
                attackStarted = false
                return
            }
            
            /// It is time for reaction attack
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.attack(playerCode: attackerPlayerCode, movesByPlayer: movesByPlayer, duelType: .reactionAttack)
            }
        } else {
            duel(currentlyDefendingPlayerTrio: attackerPlayerCode, currentlyDefendingBenderIndex: attackerBenderIndex, currentlyAttackingBender: defenderBender, currentlyDefendingBender: attackerBender, currentlyAttackingBendersTeammateBender: nil)
            updateAfterAttack(attackerPlayer: attackerPlayerCode, defenderPlayer: defenderPlayerCode, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex)
            
            attackStarted = false
            waitingMoves[attackerPlayerCode] = nil
        }
    }
    
    
    func duel(currentlyDefendingPlayerTrio: String, currentlyDefendingBenderIndex: Int, currentlyAttackingBender: Bender, currentlyDefendingBender: Bender, currentlyAttackingBendersTeammateBender: Bender?) {
        let attackWithoutAdvantages = currentlyAttackingBender.attack
        if gameMode == .twoVsTwo {
            (currentlyAttackingBender as! TeammateBender).teammate = currentlyAttackingBendersTeammateBender
            (currentlyAttackingBendersTeammateBender as? TeammateBender)?.teammate = currentlyAttackingBender
        }
        currentlyAttackingBender.opponent = currentlyDefendingBender
        currentlyDefendingBender.health = currentlyDefendingBender.health - currentlyAttackingBender.attack
        delegate?.startHealthDecreasingAnimation(by: currentlyAttackingBender.attack, currentlyDefendingPlayer: currentlyDefendingPlayerTrio, currentlyDefendingBenderIndex: currentlyDefendingBenderIndex)
        currentlyAttackingBender.attack = attackWithoutAdvantages
    }
    
    
    func updateAfterAttack(attackerPlayer: String, defenderPlayer: String, attackerBenderIndex: Int, defenderBenderIndex: Int) {
        selectedItems[attackerPlayer] = selectedItems[attackerPlayer]!.filter { $0 != attackerBenderIndex }
        selectedItems[defenderPlayer] = selectedItems[defenderPlayer]!.filter { $0 != defenderBenderIndex }
        moves[attackerPlayer] = nil
        updateProperly()
    }
    
    
    func checkIfThereIsUncompletedTeammateMove() -> Bool {
        guard !gameFinished else { return false }
        if waitingMoves.first != nil {
            state += 1
            let attackerPlayerCode = waitingMoves.keys.first!
            let movesByPlayer = waitingMoves.values.first!
            attack(playerCode: attackerPlayerCode, movesByPlayer: movesByPlayer, duelType: .firstAttack)
            let teammate = getTeammateCode(playerCode: attackerPlayerCode)
            if let teammateMoves = moves[teammate] {
                let teammateMovesKey = teammateMoves.keys.first!
                let teammateValue = teammateMoves.values.first
                selectedItems[teammateMovesKey] = selectedItems[teammateMovesKey]!.filter { $0 != teammateValue }
            }
            moves[teammate] = nil
            selectedItems[teammate] = nil
            return true
        }
        return false
    }
    
    
    func checkWinConditions() {
        var checkArray: [[Bender]] = []
        var haveLost: [String] = []
        var stillPlaying: [String] = []

        for i in 0 ..< numberOfPlayers {
            checkArray.append([])
            checkArray[i] = benders[i].filter{ $0.state == .gaveUp }
            if checkArray[i].count == 3 {
                haveLost.append(trios[i])
            } else {
                stillPlaying.append(trios[i])
            }
        }
        
        haveLost.forEach { losers.insert($0) }
        
        if losers.count == 4 {
            gameFinished = true
        }
        
        if gameMode == .ffa {
            if losers.count == 3 {
                playerCodes.forEach {
                    if !losers.contains($0) {
                        winners.append($0)
                    }
                }
                gameFinished = true
            }
        }
        
        if gameMode == .oneVsOne {
            if losers.count == 1 {
                playerCodes.forEach {
                    if !losers.contains($0) {
                        winners.append($0)
                    }
                }
                gameFinished = true
            }
        }
        
        if gameMode == .twoVsTwo {
            if let loser = losers.first {
                if let teammateLoser = teammates[loser] {
                    losers.insert(teammateLoser)
                    let localTeammateIndex = getPlayersLocalIndex(playerCode: teammates[teammateLoser]!)
                    benders[localTeammateIndex].forEach { $0.health = 0 }
                    playerCodes.forEach {
                        if !losers.contains($0) {
                            winners.append($0)
                        }
                    }
                }
                gameFinished = true
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    func updateProperly() {
        guard !gameFinished else { return }
        checkWinConditions()
        updateBendersStates()
        delegate?.updateProperly()
    }
    
    
    func setBenderStates(when: String, attackerBender: inout Bender, defenderBender: inout Bender, duelType: DuelType) {
        switch when {
        case "beforeAttackAnimation":
            if duelType == .firstAttack {
                attackerBender.state = .attacking
                defenderBender.state = .idle
            } else {
                defenderBender.state = .attacking
                attackerBender.state = .idle
            }
        case "afterAttackAnimation":
            if duelType == .firstAttack {
                attackerBender.state = .idle
                defenderBender.state = .defending
            } else {
                defenderBender.state = .idle
                attackerBender.state = .defending
            }
        default:
            return
        }
        delegate?.updateProperly()
    }
    
    
    func updateBendersStates() {
        let bendersFlatten = benders.flatMap { $0 }
        bendersFlatten.forEach { bender in
            if bender.state != .gaveUp {
                bender.state = .idle
            }
        }
        for keyValuePair in selectedItems {
            let key = keyValuePair.key
            let playerIndex = getPlayersLocalIndex(playerCode: key)
            
            let value = keyValuePair.value
            value.forEach { benderIndex in
                let bender = benders[playerIndex][benderIndex]
                if bender.state != .gaveUp {
                    bender.state = .selected
                }
            }
        }
    }
    
    
    func getTeammateBender(attackerPlayerCode: String) -> Bender? {
        guard gameMode == .twoVsTwo,
              let teammateCode = teammates[attackerPlayerCode],
              let movesByTeammate = moves[teammateCode],
              let teammateBenderIndex = movesByTeammate[teammateCode] else { return nil }
        
        let teammateIndex = getPlayersLocalIndex(playerCode: teammateCode)
        let teammateBender = benders[teammateIndex][teammateBenderIndex]
        
        return teammateBender
    }
    
    
    func getBender(playerCode: String, benderIndex: Int) -> Bender {
        let playerIndex = getPlayersLocalIndex(playerCode: playerCode)
        return benders[playerIndex][benderIndex]
    }
    
    
    func getTeammateCode(playerCode: String) -> String {
        let teammateGlobalIndex = getTeammateGlobalIndex(playerCode: playerCode)
        return playerCodes[teammateGlobalIndex]
    }
    
    
    func getTeammateGlobalIndex(playerCode: String) -> Int {
        let isFirstPlayerInTeam = isFirstPlayerInTeam(playerCode: playerCode)
        let playersGlobalIndex = getPlayersGlobalIndex(playerCode: playerCode)
        let teammateGlobalIndex = isFirstPlayerInTeam ? playersGlobalIndex + 1 : playersGlobalIndex - 1
        return teammateGlobalIndex
    }
    
    
    func isFirstPlayerInTeam(playerCode: String) -> Bool {
        let playersGlobalIndex = getPlayersGlobalIndex(playerCode: playerCode)
        return playersGlobalIndex % 2 == 0 ? true : false
    }
    
    
    func getCurrentPlayersLocalIndex() -> Int {
        let currentPlayersCode = getCurrentPlayersCode()
        return getPlayersLocalIndex(playerCode: currentPlayersCode)
    }
    
    
    func getCurrentPlayersCode() -> String {
        return playerCodes[getCurrentPlayersGlobalIndex()]
    }
    
    
    func getCurrentPlayersGlobalIndex() -> Int {
        return state % numberOfPlayers
    }
    
    
    func getThisPlayersGlobalIndex() -> Int {
        let playerCode = trios[0]
        let indexOfPlayer = getPlayersGlobalIndex(playerCode: playerCode)
        return indexOfPlayer
    }
    
    
    func getThisPlayerCode() -> String {
        return trios[0]
    }
    
    
    func getPlayersGlobalIndex(playerCode: String) -> Int {
        let playersGlobalIndex = playerCodes.firstIndex { $0 == playerCode }!
        return playersGlobalIndex
    }
    
    
    func getPlayersLocalIndex(playerCode: String) -> Int {
        let playersLocalIndex = trios.firstIndex { $0 == playerCode }!
        return playersLocalIndex
    }
    
    
    func sendApproveTimeIsUp() {
        let timeIsUpMessage = "TimeIsUp:\(getThisPlayerCode())-MoveState:\(gameCommunication.moveState)"
        gameCommunication.publishMessage(message: timeIsUpMessage)
    }
    
    
    func disconnect() {
        gameCommunication.publishMessage(message: "Disconnected:\(player.playerCode)")
    }
    
    
    // Deinit For Testing Purposes
    deinit {
        print("SpoonBenders is deallocated")
    }
}


// MARK: - GameCommunicationDelegate

extension SpoonBenders: GameCommunicationDelegate {
    
    func didPlayersUpdated() {
        gameMode = gameCommunication.gameMode
        playersAndCharacteristics = gameCommunication.players
        playerCodes = gameCommunication.playersCodes
        delegate?.updateWaitingPlayers()
    }
    
    
    func startGame() {
        playersAndBenders = gameCommunication.playersAndBenders
        let (avatars, nicknames, triosAndPlayers, benders) = setGame()
        playersAndAvatars = avatars
        playersAndNicknames = nicknames
        self.trios = triosAndPlayers
        benderNumbers = benders
        for i in 0 ..< numberOfPlayers {
            createBenders(randomNumbers: benderNumbers[i], which: i)
        }
        playerCodes.forEach { playerCode in
            let teammateCode = getTeammateCode(playerCode: playerCode)
            teammates[playerCode] = teammateCode
        }
        gameCommunication.gameStarted = true
        delegate?.goForGameVc()
    }
    
    
    func timeIsUpApproved(message: String) {
        delegate?.approveTimeIsUp()
    }
    
    
    func moveMade(by player: String, onTrio: String, at index: Int) {
        makeAMove(playerCode: player, trio: onTrio, index: index)
    }
    
    
    func didPlayerDrop(playerCode: String) {
        if gameCommunication.gameStarted {
            if let selectedTrios = moves[playerCode] {
                selectedTrios.forEach { (trio, index) in
                    selectedItems[trio] = selectedItems[trio]?.filter { $0 != index }
                }
            }
            let playersStillPlaying = playerCodes.filter { $0 != playerCode }
            playersStillPlaying.forEach { playerStillPlaying in
                if let movesByPlayer = moves[playerStillPlaying] {
                    movesByPlayer.forEach { (trio, index) in
                        if trio == playerCode {
                            moves[playerStillPlaying] = moves[playerStillPlaying]!.filter { $0.key != trio }
                        }
                    }
                }
            }
            moves[playerCode] = nil
            selectedItems[playerCode] = nil
            dropped.insert(playerCode)
            losers.insert(playerCode)
            let localIndex = getPlayersLocalIndex(playerCode: playerCode)
            benders[localIndex].forEach { $0.health = 0 }
            if gameMode == .twoVsTwo {
                losers.insert(teammates[playerCode]!)
                let localTeammateIndex = getPlayersLocalIndex(playerCode: teammates[playerCode]!)
                benders[localTeammateIndex].forEach { $0.health = 0 }
            }
            if gameMode != .ffa {
                gameFinished = true
                checkWinConditions()
                delegate?.updateProperly()
            }
        }
    }
}


// MARK: - Set Game

extension SpoonBenders {
    
    func setGame() -> ([String : String], [String : String], [String], [[Int]]) {
        var cvsAndPlayers: [String] = []
        cvsAndPlayers.append(player.playerCode)
        var playersAndAvatars: [String : String] = [:]
        playersAndAvatars[player.playerCode] = playersAndCharacteristics[player.playerCode]![0]
        var playersAndNicknames: [String : String] = [:]
        playersAndNicknames[player.playerCode] = playersAndCharacteristics[player.playerCode]![1]
        var cvsAndBenderNumbers: [[Int]] = []
        cvsAndBenderNumbers.append(playersAndBenders[player.playerCode]!)
        if gameMode == .twoVsTwo {
            let indexOfPlayer = playerCodes.firstIndex(where: { $0 == player.playerCode} )
            let teammateIndex = getTeammatesIndex(thisPlayersIndex: indexOfPlayer)
            cvsAndPlayers.append(playerCodes[teammateIndex])
            playersAndAvatars[playerCodes[teammateIndex]] = playersAndCharacteristics[playerCodes[teammateIndex]]![0]
            playersAndNicknames[playerCodes[teammateIndex]] = playersAndCharacteristics[playerCodes[teammateIndex]]![1]
            cvsAndBenderNumbers.append(playersAndBenders[playerCodes[teammateIndex]]!)
            for i in playersAndCharacteristics.keys {
                if i != player.playerCode && i != playerCodes[teammateIndex] {
                    playersAndAvatars[i] = playersAndCharacteristics[i]![0]
                    playersAndNicknames[i] = playersAndCharacteristics[i]![1]
                    cvsAndPlayers.append(i)
                    cvsAndBenderNumbers.append(playersAndBenders[i]!)
                }
            }
            return (playersAndAvatars, playersAndNicknames, cvsAndPlayers, cvsAndBenderNumbers)
        } else {
            for i in playersAndCharacteristics.keys {
                if i != player.playerCode {
                    playersAndAvatars[i] = playersAndCharacteristics[i]![0]
                    playersAndNicknames[i] = playersAndCharacteristics[i]![1]
                    cvsAndPlayers.append(i)
                    cvsAndBenderNumbers.append(playersAndBenders[i]!)
                }
            }
            return (playersAndAvatars, playersAndNicknames, cvsAndPlayers, cvsAndBenderNumbers)
        }
    }
    
    
    func getTeammatesIndex(thisPlayersIndex: Int?) -> Int {
        switch thisPlayersIndex {
        case 0:
            return 1
        case 1:
            return 0
        case 2:
            return 3
        case 3:
            return 2
        default:
            return 1
        }
    }
}
