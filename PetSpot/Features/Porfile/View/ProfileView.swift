//
//  ProfileView.swift
//  PetSpot
//
//  Created by Calvin Calvo on 20/10/2026.
//


import SwiftUI

struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    @State private var showLogoutConfirmation = false

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.68,
        blue: 0.42
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(petSpotGreen)

                    Text("A minha conta")
                        .font(.title2.bold())

                    Text("Gere o teu perfil PetSpot")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)

                Button(role: .destructive) {
                    showLogoutConfirmation = true
                } label: {
                    Label(
                        "Terminar sessão",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Perfil")
            .confirmationDialog(
                "Queres terminar a sessão?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Terminar sessão", role: .destructive) {
                    isAuthenticated = false
                }

                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Terás de iniciar sessão novamente para aceder à aplicação.")
            }
        }
    }
}
