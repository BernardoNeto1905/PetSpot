//
//  PetSpotApp.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//

import SwiftUI
import SwiftData

@main
struct PetSpotApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Pet.self)
    }
}
