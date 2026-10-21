//
//  ProfileView.swift
//  PetSpot
//
//  Created by Calvin Calvo on 20/10/2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Binding var isAuthenticated: Bool
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currentUserName") private var currentUserName: String = "Utilizador"
    @Query private var pets: [Pet]
    @Query private var users: [User]
    
    @State private var showLogoutConfirmation = false
    @State private var showAddPetSheet = false

    private let petSpotGreen = Color(red: 0.0, green: 0.68, blue: 0.42)

    // Obtém o nome real do utilizador ativo
    var userDisplayName: String {
        users.first?.name ?? currentUserName
    }
    
    // Obtém o nome do primeiro pet para a legenda "Dona/Dono do ..."
    var petOwnerSubtitle: String {
        if let firstPet = pets.first {
            return "Dono(a) do \(firstPet.name) 🐾"
        }
        return "Tutor de animais 🐾"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. CABEÇALHO (Título & Ícone PetSpot)
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
                    
                    // 2. CARTÃO DO UTILIZADOR
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
                            
                            Text(petOwnerSubtitle)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                // Ação para editar perfil
                            }) {
                                Text("Editar perfil")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(petSpotGreen)
                            }
                            .padding(.top, 2)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    // 4. SECÇÃO "A MINHA CONTA"
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
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    
                    // 5. BOTÃO "TERMINAR SESSÃO"
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                            Text("Terminar sessão")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddPetSheet) {
                AddPetView()
            }
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

// MARK: - Componente Auxiliar para as Linhas de Menu
struct ProfileMenuRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconBgColor: Color
    let iconColor: Color
    
    var body: some View {
        Button(action: { }) {
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
        }
    }
}
