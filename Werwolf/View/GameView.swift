import SwiftUI

/// Main game view that displays role cards to each player.
struct GameView: View {
    @Bindable var gameModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var cardOffset: CGFloat = 0
    @State private var isRevealed = false
    @State private var showNextButton = false
    @State private var lastHapticTrigger = false // Track haptic state
    
    private let revealThreshold: CGFloat = -150
    private let cardHeight: CGFloat = 400 // Increased from 300
    private let cardWidth: CGFloat = 280 // Increased from 200
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            if gameModel.gamePhase == .roleReveal {
                gameContent
            } else {
                completedView
            }
        }
        .sensoryFeedback(.impact, trigger: isRevealed)
        .sensoryFeedback(.impact(weight: .heavy), trigger: lastHapticTrigger)
    }
    
    private var gameContent: some View {
        VStack {
            // Progress indicator
            VStack(spacing: 8) {
                Text(gameModel.progressText)
                    .font(.headline)
                    .foregroundColor(.white)
                
                ProgressView(value: Double(gameModel.currentPlayerIndex), 
                           total: Double(gameModel.players.count - 1))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(width: 200)
                Spacer()
            }
            .frame(height: 80)
            
            Spacer()
            

            // Draggable card
            roleCard
            
            Spacer()
            // Fixed height container for instructions/button to prevent layout jumps
            VStack {
                if showNextButton {
                    // Next button
                    Button(action: nextPlayer) {
                        HStack(spacing: 12) {
                            Text(gameModel.isLastPlayer ? "Spiel beenden" : "Weitergeben")
                                .font(.headline)
                            
                            if !gameModel.isLastPlayer {
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    // Instructions
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.up")
                            .font(.title)
                            .foregroundColor(.gray)
                            .opacity(0.7)
                        
                        Text("Nach oben ziehen zum Aufdecken")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(height: 80) // Fixed height to prevent layout shifts
            .padding(.top, 40)
            
            Spacer()
        }
        .padding()
    }
    
    private var roleCard: some View {
        ZStack {
            // Bottom card - Role card (revealed when top card is dragged up)
            RoundedRectangle(cornerRadius: 24) // Increased corner radius
                .fill(Color.white)
                .frame(width: cardWidth-20, height: cardHeight-20)
                .shadow(radius: 12)
                .overlay(
                    VStack(spacing: 24) { // Increased spacing
                        if let currentPlayer = gameModel.currentPlayer,
                           let role = currentPlayer.role {
                            Spacer()
                            // Role image
                            Image(role.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160) // Increased from 120
                            
                            // Role name
                            Text(role.displayName)
                                .font(.title.bold()) // Increased from title2
                                .foregroundColor(Color("DarkBlue"))
                                .padding(.bottom)
                        }
                    }
                )
            
            // Top card - Cover card (draggable)
            RoundedRectangle(cornerRadius: 24) // Increased corner radius
                .fill(Color("DarkBlue"))
                .frame(width: cardWidth, height: cardHeight)
                .shadow(radius: cardOffset < -50 ? 24 : 12) // Increased shadow
                .overlay(
                    VStack(spacing: 20) { // Increased spacing
                        Image("dorf")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.white)
                        
                        if let currentPlayer = gameModel.currentPlayer {
                            Text(currentPlayer.name)
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                    }
                )
                .offset(y: cardOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Only allow upward dragging
                            if value.translation.height < 0 {
                                // Apply resistance - gets harder to drag as it goes higher
                                let rawOffset = value.translation.height
                                let maxDrag: CGFloat = -320 // Increased for bigger card
                                let resistance: CGFloat = 0.3
                                
                                // Apply exponential resistance curve
                                let normalizedOffset = abs(rawOffset) / abs(maxDrag)
                                let resistanceFactor = 1 - (normalizedOffset * resistance)
                                
                                cardOffset = rawOffset * max(0.2, resistanceFactor)
                                
                                // Limit maximum drag to just above the bottom card
                                cardOffset = max(cardOffset, maxDrag)
                                
                                // Trigger haptic feedback when revealed (only once per drag session)
                                if cardOffset <= revealThreshold && !isRevealed {
                                    isRevealed = true
                                    lastHapticTrigger.toggle() // Trigger haptic
                                }
                            }
                        }
                        .onEnded { value in
                            // Trigger haptic feedback on release
                            lastHapticTrigger.toggle()
                            
                            // Create bounce animation when card "drops"
                            withAnimation(.interactiveSpring(
                                response: 0.6,
                                dampingFraction: 0.6,
                                blendDuration: 0.2
                            )) {
                                cardOffset = 0
                            }
                            
                            // Add a subtle secondary bounce for more realistic physics
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(
                                    response: 0.3,
                                    dampingFraction: 0.8
                                )) {
                                    // Small bounce up and back down
                                    cardOffset = -8 // Slightly increased for bigger card
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(
                                        response: 0.2,
                                        dampingFraction: 0.9
                                    )) {
                                        cardOffset = 0
                                    }
                                }
                            }
                            
                            // Show next button after card settles
                            if isRevealed {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    showNextButton = true
                                }
                            }
                        }
                )
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 40) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Alle Rollen verteilt!")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Das Spiel kann beginnen")
                .font(.title2)
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                Button("Neue Runde") {
                    gameModel.restartGame()
                    resetView()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Zurück zur Konfiguration") {
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding()
    }
    
    private func nextPlayer() {
        gameModel.nextPlayer()
        resetView()
    }
    
    private func resetView() {
        cardOffset = 0
        isRevealed = false
        showNextButton = false
        lastHapticTrigger = false // Reset haptic state
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    let players = [
        Player(name: "Alice", role: .werewolf),
        Player(name: "Bob", role: .villager),
        Player(name: "Charlie", role: .fortuneteller)
    ]
    
    GameView(gameModel: GameViewModel(players: players))
}
