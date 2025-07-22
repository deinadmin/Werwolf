import Foundation
import SwiftUI
import Observation

/// ViewModel für die Konfiguration vor Spielstart.
/// Verantwortlich für Spieler- und Rollenzählung.
@Observable
final class GameConfigViewModel {
    // MARK: - Published Properties
    /// Aktuelle Spielerliste
    var players: [Player] = [] {
        didSet { syncRoleCountsWithPlayers() }
    }

    /// Dictionary: Wie viele von jeder Rolle?
    var roleCounts: [Role: Int] = Role.allCases.reduce(into: [:]) { $0[$1] = 0 }

    // MARK: - Init
    init() {
        // Zwei Spieler als Startwert
        players = [Player(name: "Spieler 1"), Player(name: "Spieler 2")]
        roleCounts[.villager] = players.count // Standard: alle Dorfbewohner
    }

    // MARK: - Spieler-Handling
    /// Fügt einen neuen Spieler hinzu
    func addPlayer() {
        print("[GameConfigViewModel] Spieler hinzufügen, aktuell: \(players.count)")
        // Gather all currently used numbers
        let usedNumbers = Set(
            players.compactMap { player -> Int? in
                let prefix = "Spieler "
                if player.name.hasPrefix(prefix) {
                    let rest = player.name.dropFirst(prefix.count)
                    return Int(rest.trimmingCharacters(in: .whitespaces))
                }
                return nil
            }
        )
        // Find the lowest available number
        var nextNumber = 1
        while usedNumbers.contains(nextNumber) {
            nextNumber += 1
        }
        let newName = "Spieler \(nextNumber)"
        // Prevent duplicate name (defensive, should not occur due to logic above)
        if !players.contains(where: { $0.name == newName }) {
            let newPlayer = Player(name: newName)
            players.append(newPlayer)
            print("[GameConfigViewModel] Spieler hinzugefügt, neu: \(players.count)")
        } else {
            print("[GameConfigViewModel] FEHLER: Spieler mit Name bereits vorhanden: \(newName)")
        }
        // Rolle wird automatisch synchronisiert
    }

    /// Entfernt Spieler an gegebenen Indizes
    func removePlayers(at offsets: IndexSet) {
        print("[GameConfigViewModel] Entferne Spieler an: \(offsets)")
        players.remove(atOffsets: offsets)
        print("[GameConfigViewModel] Spieler entfernt, neu: \(players.count)")
        // Rolle wird automatisch synchronisiert
    }

    /// Sortiert Spieler per Drag & Drop
    func movePlayers(from source: IndexSet, to destination: Int) {
        print("[GameConfigViewModel] Spieler verschieben von \(source) nach \(destination)")
        players.move(fromOffsets: source, toOffset: destination)
        print("[GameConfigViewModel] Spieler verschoben")
    }

    /// Aktualisiert den Namen eines Spielers
    func updatePlayerName(playerId: UUID, newName: String) {
        print("[GameConfigViewModel] Spielername ändern: \(playerId) -> \(newName)")
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            print("[GameConfigViewModel] Name erfolgreich geändert")
        } else {
            print("[GameConfigViewModel] FEHLER: Spieler nicht gefunden")
        }
    }

    // MARK: - Rollen-Handling
    /// Erhöht die Anzahl einer Rolle (außer Dorfbewohner)
    func increment(_ role: Role) {
        guard canIncrement(role) else { return }
        roleCounts[role, default: 0] += 1
        adjustVillager(by: -1)
        print("[GameConfigViewModel] \(role.displayName) erhöht, jetzt: \(roleCounts[role, default: 0])")
    }

    /// Verringert die Anzahl einer Rolle (außer Dorfbewohner)
    func decrement(_ role: Role) {
        guard roleCounts[role, default: 0] > 0 else { return }
        roleCounts[role, default: 0] -= 1
        adjustVillager(by: 1)
        print("[GameConfigViewModel] \(role.displayName) verringert, jetzt: \(roleCounts[role, default: 0])")
    }

    /// Prüft, ob eine Rolle erhöht werden darf
    func canIncrement(_ role: Role) -> Bool {
        if role.isUnique, roleCounts[role, default: 0] >= 1 { return false }
        // Es muss mindestens ein Dorfbewohner übrig sein, der ersetzt werden kann
        if roleCounts[.villager, default: 0] == 0 { return false }
        return true
    }

    // MARK: - Hilfsfunktionen
    /// Passt die Dorfbewohner-Anzahl an (immer >= 0)
    private func adjustVillager(by delta: Int) {
        roleCounts[.villager, default: 0] = max(0, (roleCounts[.villager] ?? 0) + delta)
    }

    /// Gesamtzahl aller vergebenen Rollen
    private func totalAssignedRoles() -> Int {
        roleCounts.values.reduce(0, +)
    }

    /// Synchronisiert die Rollenzählung mit der Spieleranzahl
    private func syncRoleCountsWithPlayers() {
        print("[GameConfigViewModel] Synchronisiere Rollen mit \(players.count) Spielern")
        let nonVillagerCount = totalAssignedRoles() - (roleCounts[.villager] ?? 0)
        let newVillagerCount = max(0, players.count - nonVillagerCount)
        roleCounts[.villager] = newVillagerCount
        print("[GameConfigViewModel] Dorfbewohner gesetzt auf: \(newVillagerCount)")
        // Falls zu viele Spezialrollen, werden Dorfbewohner auf 0 gesetzt
        // (UI verhindert das Hinzufügen von zu vielen Spezialrollen)
    }

    // MARK: - Game Start
    /// Creates players with assigned roles and returns them for starting a game
    func createPlayersWithRoles() -> [Player] {
        // Create a pool of roles based on the current configuration
        var rolePool: [Role] = []
        
        for (role, count) in roleCounts {
            for _ in 0..<count {
                rolePool.append(role)
            }
        }
        
        // Shuffle the roles randomly
        rolePool.shuffle()
        
        // Assign roles to players
        var gameReady: [Player] = []
        for (index, player) in players.enumerated() {
            var playerCopy = player
            if index < rolePool.count {
                playerCopy.role = rolePool[index]
            } else {
                // Fallback: assign villager if something goes wrong
                playerCopy.role = .villager
            }
            gameReady.append(playerCopy)
        }
        
        return gameReady
    }

    /// Validates if the game can be started
    var canStartGame: Bool {
        return players.count >= 2 && totalAssignedRoles() == players.count
    }
}
