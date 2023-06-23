//
//  SpoonBenders.swift
//  Spoon Benders
//
//  Created by Con Dog on 25.02.2022.
//

import Foundation

protocol SpoonBendersDelegate: AnyObject {
    
    /// Lobby Functions
    func updateWaitingPlayers()
    func goForGameVc()
    
    /// In Game Functions
    func attack(by playerCode: String, defendersTrio: String, attackerBenderIndex: Int, defenderBenderIndex: Int, duelType: DuelType)
    func updateProperly()
    func resetTimer()
    func approveTimeIsUp()
    func startHealthDecreasingAnimation(by opponentsAttack: Int, currentlyDefendingPlayer: String, currentlyDefendingBenderIndex: Int)
}


extension SpoonBendersDelegate {
    
    func updateWaitingPlayers() { }
    func goForGameVc() { }
    
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
            guard !attackStarted else { return false }
            guard !losers.contains(getCurrentPlayersCode()) else { return false }
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
            print("\n")
            guard !gameFinished, turnBased, !attackStarted else { return }
            while losers.contains(getCurrentPlayersCode()) { state += 1 }
//            print("\n__***___")
//            print(gameCommunication.moveState)
//            print("***")
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
//        print("🥹selectBender-4")
//        print(playerCodes)
//        print(losers)
//        print(teammates)
//        print("1️⃣\(isMyTurn)")
        guard turnSwitch else { return }
        guard !gameFinished else { return }
        if gameMode == .twoVsTwo,
           attackStarted { return }
        print("\n")
//        print(isMyTurn)
        guard isMyTurn else { return }
        guard !losers.contains(onPlayer) else { return }
        
        /// Check if there is no right to select more bender
        if let movesByPlayer = moves[trios[0]] {
            guard movesByPlayer.count < 2 else { return }
        }
        
        /// If game is 2v2 and current player is trying to select teammates bender
        if gameMode == .twoVsTwo,
            onPlayer == trios[1] { return }
        
        /// Index of player to move on
        let indexOfPlayer = getPlayersLocalIndex(playerCode: onPlayer)
        
        /// If current player is trying to select bender that gave up already
        guard benders[indexOfPlayer][index].state != .gaveUp else { return }
        
        /// If bender is already selected
        if let items = selectedItems[onPlayer] {
            if items.contains(index) {
                return
            }
        }
        
        let myMove = "MoveState:\(gameCommunication.moveState)=>MoveBy:\(trios[0])-MoveOn:\(onPlayer)-WhichBender:\(index)"
        
        /// MQTT - publish message
        /// MoveBy:165-MoveOn:141-WhichBender:2
        gameCommunication.publishMessage(message: myMove)
    }
    
    
    func makeAMove(playerCode: String, trio: String, index: Int) {
//        print("\n")
//        benders.flatMap { $0 }.forEach { print($0.state) }
        // let say: "165" : [cv1 : 4, cv3 : 5]
        // "165" : [....?]  It exists.
        guard let movesByPlayer = moves[playerCode] else {  // If the player has not played yet // "165" : [...?] It doesn't exist
            checkAndUpdateSelectedItems(trio: trio, index: index)
            moves[playerCode] = [:]     // "165" : [:]
            moves[playerCode]![trio] = index  // "165" : [cv2 : 1]
            updateProperly()
//            benders.flatMap { $0 }.forEach { print($0.state) }
            return
        }
        
        let cvSelectedBefore = movesByPlayer.first!.key   // cv1 (let old cv = cv1: [2, 4, 5])  // cv1
        let indexSelectedBefore = movesByPlayer.first!.value

        arrangeSelections(playerCode: playerCode, trio: trio, index: index, trioSelectedBefore: cvSelectedBefore, indexSelectedBefore: indexSelectedBefore)
        
        if let movesByPlayer = moves[playerCode],
           movesByPlayer.count == 2 {
            takeAction(playerCode: playerCode, movesByPlayer: movesByPlayer)
        }
    }
    
    
    func arrangeSelections(playerCode: String, trio: String, index: Int, trioSelectedBefore: String, indexSelectedBefore: Int) {
        // let say cv2 belongs te me.
        if trioSelectedBefore != playerCode && trio != playerCode {   // cv1 and cv3 are not belong to player // I decide to change my first item to attack on it. cv1:4 -> cv3:5
            selectedItems[trioSelectedBefore] = selectedItems[trioSelectedBefore]!.filter { $0 != indexSelectedBefore }   // No need to check if it is nil because I already know I selected it before.   // cv1: [2, 4, 5] -> [2, 5] (2 and 5 in cv1 are selected by other players.)
            checkAndUpdateSelectedItems(trio: trio, index: index)
            moves[playerCode]![trioSelectedBefore] = nil      // ("165"->) [cv1 : 4] -> ("165"->) []
            moves[playerCode]![trio] = index      // ("165"->) [cv3 : 5]
        } else if trioSelectedBefore == playerCode && trio == playerCode { // cv2 and cv2 are belong to player // I decide to change my first item as my bender. cv2:2 -> cv2:1
            selectedItems[trioSelectedBefore] = selectedItems[trioSelectedBefore]!.filter { $0 != indexSelectedBefore }   // cv2: [0, 2, 4] -> [0 ,4] (0 and 4 in cv2 are selected by other players.)
            checkAndUpdateSelectedItems(trio: trio, index: index)
            moves[playerCode]![trioSelectedBefore] = nil      // ("165"->) [cv2 : 2] -> ("165"->) []
            moves[playerCode]![trio] = index      // ("165"->) [cv2 : 1]
        } else {    // cv3 is not belong to player and cv2 is belong to player // I decide to attack with my bender (cv2: 1) to another (cv4: 5).
            checkAndUpdateSelectedItems(trio: trio, index: index)
            moves[playerCode]![trio] = index  // ("165"->) [cv2 : 1, cv4: 5]
        }
        updateProperly()
    }
    
    
    func checkAndUpdateSelectedItems(trio: String, index: Int) {
        if selectedItems[trio] != nil {   // cv3: [1,2]
            selectedItems[trio]!.append(index)    // cv3: [1, 2, 3]    (1 and 2 in cv3 are selected by other players.)
        } else {                                    // if there is no cv3 yet (If cv3 is not selected yet)
            selectedItems[trio] = []      //  cv3: []
            selectedItems[trio]!.append(index)    // cv3: [3]
        }
    }
    
    
    func takeAction(playerCode: String, movesByPlayer: [String : Int]) {
//        print("takeAction")
        if gameMode == .twoVsTwo {
//            let teammateCode = getTeammateCode(playerCode: playerCode)
//            teammates[playerCode] = teammateCode
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
        toggleAttackStarted(byPlayer: playerCode, to: true)
        
        let attackerBenderIndex = movesByPlayer[playerCode]!
        let defendersTrio = movesByPlayer.keys.filter{ $0 != playerCode }.first!
        let defenderBenderIndex = movesByPlayer[defendersTrio]!
        
        var attackerBender = getBender(playerCode: playerCode, benderIndex: attackerBenderIndex)
        var defenderBender = getBender(playerCode: defendersTrio, benderIndex: defenderBenderIndex)
        
        setBenderStates(when: "beforeAttackAnimation", attackerBender: &attackerBender, defenderBender: &defenderBender, duelType: duelType)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.delegate?.attack(by: playerCode, defendersTrio: defendersTrio, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex, duelType: duelType)
        }
    }
    
    
    // MARK: - Duel
    
    func prepareDuel(attackerPlayerCode: String, duelType: DuelType) {
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
        if duelType == .firstAttack {
            duel(currentlyDefendingPlayerTrio: defenderPlayerCode, currentlyDefendingBenderIndex: defenderBenderIndex, currentlyAttackingBender: attackerBender, currentlyDefendingBender: defenderBender, currentlyAttackingBendersTeammateBender: teammateBender)
            updateProperly()

            /// Check if defender bender gave up
            if defenderBender.health == 0 {
                waitingMoves[attackerPlayerCode] = nil
                updateAfterAttack(attackerPlayer: attackerPlayerCode, defenderPlayer: defenderPlayerCode, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex)
                if gameMode == .twoVsTwo {
                    
                    /// After first attack, if duel is finished and If there is teammates waiting move, it should wait for it.
                    if waitingMoves[teammates[attackerPlayerCode]!] != nil {
                        return
                    }
                }
//                attackStarted = false
                toggleAttackStarted(byPlayer: attackerPlayerCode, to: false)
                return
            }
            
            /// It is time for reaction attack
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.attack(playerCode: attackerPlayerCode, movesByPlayer: movesByPlayer, duelType: .reactionAttack)
            }
        } else {
            duel(currentlyDefendingPlayerTrio: attackerPlayerCode, currentlyDefendingBenderIndex: attackerBenderIndex, currentlyAttackingBender: defenderBender, currentlyDefendingBender: attackerBender, currentlyAttackingBendersTeammateBender: nil)
            updateAfterAttack(attackerPlayer: attackerPlayerCode, defenderPlayer: defenderPlayerCode, attackerBenderIndex: attackerBenderIndex, defenderBenderIndex: defenderBenderIndex)
            
//            print("makeDuel-attackStarted = false")
//            attackStarted = false
            toggleAttackStarted(byPlayer: attackerPlayerCode, to: false)
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
        if currentlyDefendingBender.health < 0 { currentlyDefendingBender.health = 0 }
//        print("\n---duel---, \(defendingPlayerTrio)")
//        print(defenderBenderIndex)
        delegate?.startHealthDecreasingAnimation(by: currentlyAttackingBender.attack, currentlyDefendingPlayer: currentlyDefendingPlayerTrio, currentlyDefendingBenderIndex: currentlyDefendingBenderIndex)
        currentlyAttackingBender.attack = attackWithoutAdvantages
    }
    
    
    func updateAfterAttack(attackerPlayer: String, defenderPlayer: String, attackerBenderIndex: Int, defenderBenderIndex: Int) {
        selectedItems[attackerPlayer] = selectedItems[attackerPlayer]!.filter { $0 != attackerBenderIndex }
        selectedItems[defenderPlayer] = selectedItems[defenderPlayer]!.filter { $0 != defenderBenderIndex }
        moves[attackerPlayer] = nil
        
//        checkWinConditions()
//        turnSwitch = true
        updateProperly()
    }
    
    
    func checkIfThereIsUncompletedTeammateMove() -> Bool {
//        print("checkIfThereIsUncompletedTeammateMove")
        if let _ = waitingMoves.first {
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
        print("\n")
        var checkArray: [[Bender]] = []
        var haveLost: [String] = []
        var stillPlaying: [String] = []

        for i in 0 ..< numberOfPlayers {
            print("number of players: \(numberOfPlayers)")
            print("-4")
            checkArray.append([])
            checkArray[i] = benders[i].filter{ $0.state == .gaveUp }
            
            if checkArray[i].count == 3 {
                print("-5")
                haveLost.append(trios[i])
            } else {
                print("-6")
                stillPlaying.append(trios[i])
            }
        }
        print("LOSERS:")
        print(losers)
        
        haveLost.forEach { losers.insert($0) }
//        losers += haveLost
        
        if losers.count == 4 {
            print("-999")
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
        
        print("LOOOOOOOSERS:")
        print(losers)
    }
    
    
    // MARK: - Helper Functions
    
    func updateProperly() {
        checkWinConditions()
        turnSwitch = true
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
        return playerCodes[teammateGlobalIndex] // IOR
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
    
    
    func didClean() {
        moves.removeAll()
        selectedItems.removeAll()
        updateProperly()
    }
    
    
    func toggleAttackStarted(byPlayer: String, to: Bool) {
//        print("toggleAttackStarted")
        attackStarted = to
        let message = to ? "Attack-Started:\(byPlayer)" : "Attack-Stopped:\(byPlayer)"
        gameCommunication.publishMessage(message: message)
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
//        print(gameCommunication.moveState)
    }
    
    
    func timeIsUpApproved(message: String) {
        delegate?.approveTimeIsUp()
    }
    
    
    func moveMade(by player: String, onTrio: String, at index: Int) {
        makeAMove(playerCode: player, trio: onTrio, index: index)
    }
    
    
    func didPlayerDrop(playerCode: String) {
        if gameCommunication.gameStarted {
            dropped.insert(playerCode)
            losers.insert(playerCode)
            let localIndex = getPlayersLocalIndex(playerCode: playerCode)
            benders[localIndex].forEach { $0.health = 0 }
            if gameMode == .twoVsTwo {
                losers.insert(teammates[playerCode]!)
                let localTeammateIndex = getPlayersLocalIndex(playerCode: teammates[playerCode]!)
                benders[localTeammateIndex].forEach { $0.health = 0 }
            }
//            print(playerCodes)
//            print(losers)
//            print(teammates)
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
