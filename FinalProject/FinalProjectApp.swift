//
//  FinalProjectApp.swift
//  FinalProject
//
//  Created by Colby Barrett on 7/23/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore


@main
struct YourApp: App {
    @State var games = [Game]()
    init() {
        FirebaseApp.configure()
    }
  var body: some Scene {
    WindowGroup {
      NavigationView {
          ContentView(games: games)
      }
    }
  }
}
