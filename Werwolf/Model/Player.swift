import Foundation
import Observation

/// Represents a player participating in the Werwolf game.
/// Represents a player participating in the Werwolf game.
struct Player: Identifiable, Codable, Equatable, Hashable {
    // MARK: - Properties
    let id: UUID
    var name: String
    /// Role will be assigned once the game starts.
    var role: Role?

    // MARK: - Init
    init(name: String, role: Role? = nil) {
        self.id = UUID()
        self.name = name
        self.role = role
    }

    // MARK: - Conformance
    static func == (lhs: Player, rhs: Player) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
