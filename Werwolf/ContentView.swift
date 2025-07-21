//
//  ContentView.swift
//  Werwolf
//
//  Created by Carl on 20.07.25.
//

import SwiftUI

struct ContentView: View {
    @State private var model = GameConfigViewModel() // ViewModel bleibt erhalten
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            // Main start screen
            VStack(spacing: 40) {
                Spacer()
                Text("Werwölfe")
                    .font(.largeTitle.bold())
                Spacer()
                NavigationLink(value: Screen.config) {
                    Text("Spiel starten")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .navigationDestination(for: Screen.self) { screen in
                switch screen {
                case .config:
                    GameConfigView(model: model) // immer das gleiche Model weitergeben
                }
            }
        }
        .background(Color("DarkBlue").ignoresSafeArea())
    }

    private enum Screen: Hashable {
        case config
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
