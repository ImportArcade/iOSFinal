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
extension Color {
    static let zeldaGreenLight = Color(red: 133/255, green: 185/255, blue: 58/255) // Light green
    static let zeldaGreenDark = Color(red: 58/255, green: 110/255, blue: 46/255) // Dark green
    static let zeldaGold = Color(red: 255/255, green: 215/255, blue: 0/255) // Gold
}


struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var games: [Game]
    @State var dbObjects = [DbObject]()
    @State var completedGames: [String: Bool] = [:]
    var body: some View {
        NavigationView {
            List {
                ForEach(games) { game in
                    NavigationLink(destination: GameView(games: $games, game: game)) {
                        HStack {
                            Image(systemName: completedGames[game.id, default: false] ? "triangle.fill" : "triangle").foregroundColor(Color.zeldaGold)
                            Text("\(game.name)")
                                .foregroundColor(.zeldaGold) // Gold text color
                                .padding()
                                
                            .cornerRadius(8)
                        }.onAppear {
                            let db = Firestore.firestore()
                            let docRef = db.collection("gameData").document(game.id)
                            docRef.getDocument { (document, error) in
                                if let document = document {
                                    let isComplete = document.data()?["IsComplete"] as? Bool ?? false
                                    completedGames.updateValue(isComplete, forKey: game.id)
                                }
                            }
                        } // Rounded corners
                    } // Light green background
                }.background(Color.zeldaGreenLight.ignoresSafeArea())
            }
            .padding().listStyle(.inset)
            .navigationTitle("Zelda Games") // Add a navigation title
            .onAppear {
                Task {
                    games = try await performAPICall()
                }
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


