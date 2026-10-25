//
//  CommunityView.swift
//  PetSpot
//
//  Created by Bernardo on 16/10/2026.
//

import SwiftUI

// MARK: - Modelos de Dados
struct CommunityPost: Identifiable {
    let id = UUID()
    let authorName: String
    let initials: String
    let petName: String
    let petEmoji: String
    let timeAgo: String
    let category: String
    let content: String
    var likesCount: Int
    var commentsCount: Int
}

struct UrgentAlert: Identifiable {
    let id = UUID()
    let petName: String
    let location: String
    let timeAgo: String
}

// MARK: - CommunityView Principal
struct CommunityView: View {
    @State private var selectedFilter = "Geral"
    @State private var showingAddAlert = false

    let filters = ["Geral", "Pets Perdidos", "Encontros", "Dicas"]
    
    // Dados de demonstração
    @State private var urgentAlert = UrgentAlert(
        petName: "Bobi",
        location: "Parque do Avlis",
        timeAgo: "há 20 min"
    )
    
    @State private var posts: [CommunityPost] = [
        CommunityPost(
            authorName: "João Silva",
            initials: "JS",
            petName: "Bobi",
            petEmoji: "🐕",
            timeAgo: "há 5 min",
            category: "Encontro no Parque",
            content: "Alguém vai hoje às 17h ao Parque de Cães? O Bobs quer brincar!",
            likesCount: 12,
            commentsCount: 4
        ),
        CommunityPost(
            authorName: "Ana P.",
            initials: "AP",
            petName: "Luna",
            petEmoji: "🐈",
            timeAgo: "há 2 h",
            category: "Dica / Pergunta",
            content: "Qual é a melhor ração para gatos castrados com estômago sensível? Recomendações?",
            likesCount: 8,
            commentsCount: 6
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header Title
                        HStack {
                            Text("Comunidade")
                                .font(.system(size: 32, weight: .bold))
                            
                            Spacer()
                            
                            // Ícone Superior
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "pawprint.fill")
                                    .foregroundColor(Color(red: 0.0, green: 0.65, blue: 0.45))
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // 1. Filtros por Categoria (ScrollView Horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(filters, id: \.self) { filter in
                                    Button(action: {
                                        selectedFilter = filter
                                    }) {
                                        Text(filter)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedFilter == filter ?
                                                Color(red: 0.0, green: 0.65, blue: 0.45) :
                                                Color.white
                                            )
                                            .foregroundColor(
                                                selectedFilter == filter ? .white : .gray
                                            )
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(selectedFilter == filter ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // 2. Card de Alerta Urgente (Pet Perdido)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Text("🚨")
                                Text("ALERTA PET PERDIDO:")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(Color(red: 0.75, green: 0.25, blue: 0.15))
                            }
                            
                            Text("Cão '\(urgentAlert.petName)' desaparecido perto do \(urgentAlert.location) (\(urgentAlert.timeAgo))")
                                .font(.body)
                                .foregroundColor(Color(red: 0.75, green: 0.25, blue: 0.15))

                            Button(action: {
                                // Ação para ver detalhes
                            }) {
                                Text("Ver Detalhes / Ajudar")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0.82, green: 0.32, blue: 0.15))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 1.0, green: 0.94, blue: 0.92))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.98, green: 0.80, blue: 0.75), lineWidth: 1)
                        )
                        .padding(.horizontal)

                        // 3. Lista de Publicações
                        VStack(spacing: 12) {
                            ForEach(posts) { post in
                                PostCardView(post: post)
                            }
                        }
                        .padding(.horizontal)

                        // Espaçamento inferior para acomodar o botão flutuante
                        Spacer()
                            .frame(height: 80)
                    }
                }

                // 4. Barra Inferior / FAB (Floating Action Button)
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Partilha com a comunidade")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Foto, pergunta ou alerta de pet perdido")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddAlert.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color(red: 0.0, green: 0.65, blue: 0.45))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddAlert) {
                AddAlertView { newAlert in
                    // Lógica ao guardar novo alerta
                }
            }
        }
    }
}

// MARK: - Componente do Card de Post
struct PostCardView: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header do Post
            HStack {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(red: 0.90, green: 0.95, blue: 0.92))
                        .frame(width: 42, height: 42)
                    Text(post.initials)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.60, green: 0.50, blue: 0.20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(post.authorName)
                            .font(.headline)
                        Text("• com \(post.petName)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text(post.petEmoji)
                    }
                    
                    HStack(spacing: 4) {
                        Text(post.timeAgo)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(post.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0.0, green: 0.60, blue: 0.40))
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Conteúdo
            Text(post.content)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Divider()
                .padding(.top, 4)
            
            // Rodapé do Post (Ações)
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "pawprint.fill")
                        .font(.caption)
                    Text("\(post.likesCount)")
                        .font(.subheadline)
                }
                .foregroundColor(Color(red: 0.0, green: 0.60, blue: 0.40))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.caption)
                    Text("\(post.commentsCount)")
                        .font(.subheadline)
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                        Text("Partilhar")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                }
            }
            .padding(.top, 2)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
}
