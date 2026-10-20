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
    // Guarda o estado de autenticação no dispositivo para não pedir login de cada vez que a app abre
    @AppStorage("isAuthenticated")
    private var isAuthenticated: Bool = false

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                // Se estiver autenticado, apresenta a interface principal da App
                MainTabView(isAuthenticated: $isAuthenticated)
            } else {
                // Caso contrário, apresenta o ecrã de Login / Registo
                AuthView(isAuthenticated: $isAuthenticated)
            }
        }
        .modelContainer(for: [Reminder.self, Pet.self, User.self])
    }
}


