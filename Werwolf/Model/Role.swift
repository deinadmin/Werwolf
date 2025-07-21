import Foundation

/// Represents the different roles available in the Werwolf game.
/// The raw value is the asset name used in the asset catalog.
public enum Role: String, Codable, CaseIterable, Identifiable {
    // MARK: - Cases
    case villager      = "dorfbewohner"
    case werewolf      = "werwölfe"
    case fortuneteller = "seherin"
    case witch         = "hexe"
    case amor          = "amor"

    // MARK: - Identifiable
    public var id: Self { self }

    // MARK: - Helpers
    /// Human-readable name for UI.
    public var displayName: String {
        switch self {
        case .villager:      return "Dorfbewohner"
        case .werewolf:      return "Werwolf"
        case .fortuneteller: return "Seherin"
        case .witch:         return "Hexe"
        case .amor:          return "Amor"
        }
    }

    /// Indicates whether the role may only exist once per game.
    public var isUnique: Bool {
        switch self {
        case .witch, .fortuneteller, .amor: return true
        default: return false
        }
    }
}
