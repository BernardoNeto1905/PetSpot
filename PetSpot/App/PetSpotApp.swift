//
//  PetSpotApp.swift
//  PetSpot
//
//  Created by Bernardo on 09/10/2026.
//


import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

@main
struct PetSpotApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            PetSpotRootView()
        }
    }
}

struct PetSpotRootView: View {
    @Environment(\.modelContext)
    private var modelContext

    @AppStorage("isAuthenticated")
    private var isAuthenticated = false

    @AppStorage("currentUserID")
    private var currentUserID = ""

    @AppStorage("currentUserName")
    private var currentUserName = "Utilizador"

    @State private var isCheckingSession = true

    var body: some View {
        Group {
            if isCheckingSession {
                ProgressView("A verificar sessão...")
            } else if isAuthenticated {
                MainTabView(
                    isAuthenticated: $isAuthenticated
                )
            } else {
                AuthView(
                    isAuthenticated: $isAuthenticated
                )
            }
        }
        .task {
            validateSession()
        }
    }

    private func validateSession() {
        defer {
            isCheckingSession = false
        }

        guard let user = Auth.auth().currentUser else {
            clearSession()
            return
        }

        currentUserID = user.uid
        currentUserName = user.displayName ?? "Utilizador"
        isAuthenticated = true
    }
    
    private func clearSession() {
        currentUserID = ""
        currentUserName = "Utilizador"
        isAuthenticated = false
    }
}
