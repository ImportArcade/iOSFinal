import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct GameView: View {
    @Binding var games: [Game]
    @State var game: Game
    @State var notes = ""
    @State var isComplete = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text(game.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.zeldaGold) // Gold color for the title
                
                Text(game.description)
                    .font(.body)
                    .foregroundColor(.white) // Text color
                
                Text("Developer: \(game.developer)")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Text("Released: \(game.released_date)")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Text("Publisher: \(game.publisher)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                TextField("Notes", text: $notes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.zeldaGreenLight) // Light green background for the text field
                    .cornerRadius(8)
                
                Toggle(isOn: $isComplete) {
                    Text("Mark Complete")
                        .foregroundColor(.white) // Toggle label color
                }
                .toggleStyle(SwitchToggleStyle(tint: .zeldaGold)) // Gold tint for the toggle
            }
            .padding()
            .background(Color.zeldaGreenDark.ignoresSafeArea()) // Dark green background for the entire view
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Save notes and isComplete to DB
                        let db = Firestore.firestore()
                        let docRef = db.collection("gameData").document(game.id)
                        docRef.updateData(["notes": notes, "IsComplete": isComplete]) // Updated to save `isComplete`
                        dismiss()
                    }) {
                        Text("Save")
                            .foregroundColor(.zeldaGold) // Gold color for button
                    }
                }
            }
        }
        .onAppear {
            let db = Firestore.firestore()
            let docRef = db.collection("gameData").document(game.id)
            docRef.getDocument { (document, error) in
                if let document = document {
                    notes = document.data()?["notes"] as? String ?? ""
                    isComplete = document.data()?["IsComplete"] as? Bool ?? false
                }
            }
        }
    }
}

#Preview {
    @State var games = [Game]()
    @State var game = Game(name: "testName", description: "testDesc", developer: "testDev", publisher: "testPub", released_date: "testDate", id: "testId")
    return GameView(games: $games, game: game)
}
