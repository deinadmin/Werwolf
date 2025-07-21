import SwiftUI
import Observation
import UniformTypeIdentifiers

/// View zur Verwaltung der Spieler (hinzufügen, umbenennen, sortieren, löschen)
struct PlayerListView: View {
    @Bindable var model: GameConfigViewModel
    @State private var showDeleteAlert = false
    @State private var playerToDelete: Player? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            // Die große Karte
            ZStack {
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                List {
                    ForEach(model.players) { player in
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color("DarkBlue"))
                                .font(.title2)
                            TextField("Name", text: Binding(
                                get: { player.name },
                                set: { newName in
                                    model.updatePlayerName(playerId: player.id, newName: newName)
                                })
                            )
                            .textFieldStyle(.plain)
                            .font(.body)
                            .tint(.darkBlue)
                            .foregroundColor(Color("DarkBlue"))
                            .disableAutocorrection(true)
                            .autocapitalization(.words)
                            Spacer()
                            Button(action: {
                                playerToDelete = player
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onMove(perform: model.movePlayers)
                }
                .listStyle(.plain)
                .colorScheme(.light)
                .listRowBackground(Color.white)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scrollContentBackground(.hidden)
                .padding(0)
            }
            .padding(.horizontal)
            .frame(maxWidth: 500)
            
            Button(action: {
                model.addPlayer()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Spieler hinzufügen")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(Color.darkBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .navigationTitle("Spieler verwalten")
        .background(Color.darkBlue.ignoresSafeArea())
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Spieler entfernen"),
                message: Text("Möchtest du wirklich \(playerToDelete?.name ?? "") entfernen?"),
                primaryButton: .destructive(Text("Entfernen")) {
                    if let player = playerToDelete, let idx = model.players.firstIndex(where: { $0.id == player.id }) {
                        model.removePlayers(at: IndexSet(integer: idx))
                    }
                    playerToDelete = nil
                },
                secondaryButton: .cancel {
                    playerToDelete = nil
                }
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        PlayerListView(model: GameConfigViewModel())
            .preferredColorScheme(.dark)
    }
}
