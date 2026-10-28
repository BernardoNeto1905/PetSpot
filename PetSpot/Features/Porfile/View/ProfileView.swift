
//
//  ProfileView.swift
//  PetSpot
//
//  Created by Calvin Calvo on 20/10/2026.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @Binding var isAuthenticated: Bool

    @AppStorage("currentUserName")
    private var currentUserName = "Utilizador"

   @AppStorage("currentUserID")
    private var currentUserID = ""

    @State private var pets: [Pet] = []
    @State private var showLogoutConfirmation = false
    @State private var showAddPetSheet = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showEditProfile = false

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.68,
        blue: 0.42
    )

    private var userDisplayName: String {
        let name = currentUserName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !name.isEmpty && name != "Utilizador" {
            return name
        }

        return Auth.auth().currentUser?.displayName
            ?? "Utilizador"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Cabeçalho
                    HStack {
                        Text("Perfil")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(petSpotGreen)
                                .frame(width: 38, height: 38)

                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Cartão do utilizador
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .foregroundColor(.gray.opacity(0.6))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(userDisplayName)
                                .font(.system(size: 22, weight: .bold))

                            Button("Editar perfil") {
                                showEditProfile = true
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(petSpotGreen)
                            .padding(.top, 2)
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(
                        color: .black.opacity(0.04),
                        radius: 8,
                        x: 0,
                        y: 3
                    )
                    .padding(.horizontal)

                    // A minha conta
                    VStack(alignment: .leading, spacing: 12) {
                        Text("A minha conta")
                            .font(.system(size: 18, weight: .bold))

                        VStack(spacing: 0) {
                            ProfileMenuRow(
                                title: "Dados pessoais",
                                subtitle: "Nome e contactos",
                                icon: "person.fill",
                                iconBgColor: Color.green.opacity(0.15),
                                iconColor: .green
                            )

                            Divider().padding(.leading, 64)

                            ProfileMenuRow(
                                title: "Notificações",
                                subtitle: "Lembretes e cuidados",
                                icon: "bell.fill",
                                iconBgColor: Color.orange.opacity(0.15),
                                iconColor: .orange
                            )

                            Divider().padding(.leading, 64)

                            ProfileMenuRow(
                                title: "Privacidade e segurança",
                                subtitle: "Protege a tua conta",
                                icon: "checkmark.shield.fill",
                                iconBgColor: Color.teal.opacity(0.15),
                                iconColor: .teal
                            )

                            Divider().padding(.leading, 64)

                            ProfileMenuRow(
                                title: "Ajuda e apoio",
                                subtitle: "Estamos aqui para ajudar",
                                icon: "questionmark.circle.fill",
                                iconBgColor: Color.mint.opacity(0.15),
                                iconColor: .mint
                            )
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(
                            color: .black.opacity(0.04),
                            radius: 8,
                            x: 0,
                            y: 3
                        )
                    }
                    .padding(.horizontal)

                    // Terminar sessão
                    Button {
                        showLogoutConfirmation = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(
                                systemName:
                                    "rectangle.portrait.and.arrow.right"
                            )

                            Text("Terminar sessão")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(
                            color: .black.opacity(0.03),
                            radius: 6,
                            x: 0,
                            y: 2
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }
            .background(
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
            )
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await loadProfile()
            }
            .refreshable {
                await loadProfile()
            }
            .sheet(isPresented: $showAddPetSheet) {
                AddPetView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView { updatedName, updatedEmail in
                    currentUserName = updatedName
                }
            }
            
            .alert(
                "Terminar sessão",
                isPresented: $showLogoutConfirmation
            ) {
                Button("Terminar sessão", role: .destructive) {
                    logout()
                }

                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Queres terminar sessão da tua conta no PetSpot?")
            }
            
            .alert(
                "Erro",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Carregar perfil e animais do Firebase

    @MainActor
    private func loadProfile() async {
        guard let user = Auth.auth().currentUser else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        currentUserID = user.uid

        if let displayName = user.displayName,
           !displayName.isEmpty {
            currentUserName = displayName
        }

        do {
            // Carregar animais da conta autenticada.
            pets = try await PetService.fetchPets()

            // Tentar obter o nome guardado no perfil Firestore.
            let document = try await Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .getDocument()

            if let data = document.data(),
               let name = data["name"] as? String,
               !name.trimmingCharacters(
                    in: .whitespacesAndNewlines
               ).isEmpty {
                currentUserName = name
            }
        } catch {
            errorMessage =
                "Não foi possível carregar todos os dados do perfil: "
                + error.localizedDescription
        }
    }

    // MARK: - Terminar sessão Firebase

    private func logout() {
        do {
            try Auth.auth().signOut()

            currentUserID = ""
            currentUserName = "Utilizador"
            isAuthenticated = false
            pets = []
        } catch {
            errorMessage =
                "Não foi possível terminar a sessão: "
                + error.localizedDescription
        }
    }
}

// MARK: - Componente auxiliar

struct ProfileMenuRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconBgColor: Color
    let iconColor: Color

    var body: some View {
        Button(action: {
            // Implementar a navegação de cada opção futuramente.
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBgColor)
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
