//
//  ContentView.swift
//  FinalProject
//
//  Created by Colby Barrett on 7/23/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// Reference to Firestore

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var games: [Game]
    var body: some View {
        NavigationView{
            List(){
                ForEach(games) {
                    game in NavigationLink(destination: GameView(games: $games, game: game)) {
                        Text("\(game.name)")
                    }
                    }
                }
            }
            .padding().onAppear{
                Task{
                    games = try await performAPICall()
                }
            }
        }
    }
#Preview {
    @State var games = [Game]()
    return ContentView(games: games)
}

func performAPICall() async throws -> [Game] {
    let url = URL(string: "https://zelda.fanapis.com/api/games")!
    let (data, _) = try await URLSession.shared.data(from: url)
    let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
    for game in wrapper.data {
        do {
            let db = Firestore.firestore()
            let docRef = db.collection("gameData").document(game.id)
            try await docRef.getDocument { (document, error) in
                if let document = document {
                    if document.exists {
                        print("Doc already exists")
                    }
                    else {
                        docRef.setData([
                            "notes": "",
                            "IsComplete": false
                        ])
                        print("Document created")
                    }
                }
            }
        }
        catch {
            print("Error for some reason")
        }
    }
    return wrapper.data
}

struct Wrapper: Codable {
    let success: Bool
    let count: Int
    let data: [Game]
}

struct Game: Codable, Identifiable {
    let name: String
    let description: String
    let developer: String
    let publisher: String
    let released_date: String
    let id: String
    //var notes: String
}

struct DbObject: Decodable, Identifiable {
    var notes: String
    //id is the game's id, only one dbObject per gameId
    var id: String
    var isComplete: Bool
}


