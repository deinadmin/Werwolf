import Foundation
import SwiftUI
import Observation

/// ViewModel for managing the active Werewolf game round.
@Observable
final class GameViewModel {
    // MARK: - Properties
    private(set) var players: [Player] = []
    private(set) var currentPlayerIndex: Int = 0
    private(set) var gamePhase: GamePhase = .roleReveal
    
    enum GamePhase {
        case roleReveal
        case completed
    }
    
    // MARK: - Computed Properties
    var currentPlayer: Player? {
        guard currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
    
    var isLastPlayer: Bool {
        currentPlayerIndex >= players.count - 1
    }
    
    var progressText: String {
        "Spieler \(currentPlayerIndex + 1) von \(players.count)"
    }
    
    // MARK: - Init
    init(players: [Player]) {
        self.players = players
    }
    
    // MARK: - Actions
    func nextPlayer() {
        if currentPlayerIndex < players.count - 1 {
            currentPlayerIndex += 1
        } else {
            gamePhase = .completed
        }
    }
    
    func restartGame() {
        currentPlayerIndex = 0
        gamePhase = .roleReveal
    }
}