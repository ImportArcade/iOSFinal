//
//  GameView.swift
//  FinalProject
//
//  Created by Colby Barrett on 7/25/24.
//

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
            VStack {
                Text(game.name)
                Text(game.description)
                Text(game.developer)
                Text(game.released_date)
                Text(game.publisher)
                TextField("Notes", text: $notes)
                Toggle(isOn: $isComplete) {
                    Text("Mark Complete")
                }
            }}.onAppear{
                let db = Firestore.firestore()
                let docRef = db.collection("gameData").document(game.id)
                docRef.getDocument { (document, error) in
                    if let document = document {
                        notes = document.data()?["notes"] as? String ?? ""
                        isComplete = document.data()?["IsComplete"] as? Bool ?? false
                    }
                }
            }.navigationTitle("Edit Item").navigationBarBackButtonHidden(true).toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // save notes and isComplete to DB
                    let db = Firestore.firestore()
                    let docRef = db.collection("gameData").document(game.id)
                    docRef.updateData(["notes": notes, "IsComplete": true])
                    dismiss()
                }) {
                    Text("Save")
                }
            }
        }
    }
}

#Preview {
    @State var games = [Game]()
    @State var game = Game(name: "testName", description: "testDesc", developer: "testDev", publisher: "testPub", released_date: "testDate", id: "testId"//, notes: "testNotes"
    )
    return GameView(games: $games, game: game)
}
