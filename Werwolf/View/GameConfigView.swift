import SwiftUI
import Observation

/// Screen that allows the user to configure players and roles before starting the game.
struct GameConfigView: View {
    // Injected reference to the model; changes automatically update the view.
    @Bindable var model: GameConfigViewModel

    var body: some View {
                ScrollView {
                        VStack(spacing: 24) {
                                // Player management link
                NavigationLink(destination: PlayerListView(model: model)) {
                                            HStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.trailing, 8)
                            VStack(alignment: .leading) {
                                Text("Spieler verwalten")
                                    .font(.headline.bold())
                                Text("\(model.players.count) Spieler")
                                    .font(.subheadline)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                }
                rolesSection
            }
            .padding()
        }
        .navigationTitle("Spiel konfigurieren")
        .background(Color.darkBlue.ignoresSafeArea())
        
    }

    // MARK: - Subviews
    private struct RoleSettingView: View {
        let role: Role
        let editable: Bool
        @Bindable var model: GameConfigViewModel

        var body: some View {
            HStack {
                Image(role.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.displayName)
                        .font(.title3.bold())
                    Text("\(model.roleCounts[role, default: 0])")
                        .font(.subheadline)
                }
                Spacer()
                if editable {
                    Button(action: { model.decrement(role) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(model.roleCounts[role, default: 0] == 0)
                    .padding(.horizontal, 4)
                    Button(action: { model.increment(role) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                    .disabled(!model.canIncrement(role))
                }
            }
            .padding()
            .background(.white)
            .foregroundStyle(Color("DarkBlue"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }


    private var rolesSection: some View {
        VStack(spacing: 16) {
            ForEach(Role.allCases, id: \.self) { role in
                RoleSettingView(role: role,
                                editable: role != .villager,
                                model: model)
            }
        }
    }


}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameConfigView(model: GameConfigViewModel())
            .preferredColorScheme(.dark)
    }
}
