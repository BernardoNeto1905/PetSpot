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
            PetSpotRootView()
        }
        .modelContainer(
            for: [
                User.self,
                Reminder.self,
                Pet.self
            ]
        )
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

        guard !currentUserID.isEmpty else {
            clearSession()
            return
        }

        do {
            guard let user = try LocalAuthService.findUser(
                id: currentUserID,
                context: modelContext
            ) else {
                clearSession()
                return
            }

            currentUserName = user.name
            isAuthenticated = true

        } catch {
            clearSession()
            print(
                "Erro ao verificar sessão: \(error)"
            )
        }
    }

    private func clearSession() {
        currentUserID = ""
        currentUserName = "Utilizador"
        isAuthenticated = false
    }
}
