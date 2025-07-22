import SwiftUI
import Observation
import UniformTypeIdentifiers

/// View zur Verwaltung der Spieler (hinzufügen, umbenennen, sortieren, löschen)
struct PlayerListView: View {
    @Bindable var model: GameConfigViewModel
    @FocusState private var focusedPlayerId: UUID?

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
                            SelectAllTextField(
                                text: Binding(
                                    get: { player.name },
                                    set: { newName in
                                        model.updatePlayerName(playerId: player.id, newName: newName)
                                    }
                                ),
                                placeholder: "Name",
                                isFocused: Binding(
                                    get: { focusedPlayerId == player.id },
                                    set: { isFocused in
                                        if isFocused {
                                            focusedPlayerId = player.id
                                        } else if focusedPlayerId == player.id {
                                            focusedPlayerId = nil
                                        }
                                    }
                                )
                            )
                            .tint(.darkBlue)
                            .focused($focusedPlayerId, equals: player.id)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .onMove(perform: model.movePlayers)
                    .onDelete { indexSet in
                        model.removePlayers(at: indexSet)
                    }
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
                if let lastId = model.players.last?.id {
                    focusedPlayerId = lastId
                }
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
    }
}

struct SelectAllTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.textColor = UIColor(named: "DarkBlue")
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
            uiView.selectAll(nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SelectAllTextField
        init(parent: SelectAllTextField) {
            self.parent = parent
        }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFocused = false
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFocused = true
            textField.selectAll(nil)
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
