//
//  PetListView.swift
//  PetSpot
//
//  Created by Bernardo on 21/10/2026.
//

import SwiftUI
import SwiftData

struct PetListView: View {
    @Query private var pets: [Pet]
    @Query private var reminders: [Reminder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddPetSheet = false
    
    @AppStorage("currentUserName") private var userName: String = "Utilizador"
    @Query private var users: [User]
    
    private let petSpotGreen = Color(red: 0.0, green: 0.68, blue: 0.42)
    
    // Filtra apenas os lembretes agendados para a data de hoje
    var todayReminders: [Reminder] {
        let calendar = Calendar.current
        return reminders.filter { calendar.isDateInToday($0.date) }
    }
    
    var completedRemindersCount: Int {
        todayReminders.filter { $0.isCompleted }.count
    }

    var currentUserDisplayName: String {
        users.first?.name ?? userName
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // 1. CABEÇALHO (Logótipo, Notificações e Perfil)
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "pawprint.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(petSpotGreen)
                            
                            Text("PetSpot")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(petSpotGreen)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // Ícone de Notificações com ponto de alerta
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 20))
                                    .padding(8)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(Circle())
                                
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -2, y: 2)
                            }
                            
                            // Imagem de Perfil
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 38, height: 38)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 2. SAUDAÇÃO PERSONALIZADA
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Olá, \(currentUserDisplayName)!")
                                .font(.system(size: 28, weight: .bold))
                            
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                        
                        Text("Um dia feliz começa com bons cuidados.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // 3. CARROSSEL DE ANIMAIS (Os meus pets)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Os meus pets")
                                .font(.title3)
                                .bold()
                            
                            Spacer()
                            
                            Text("\(pets.count) companheiro\(pets.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                // Cartões dos Animais Existentes
                                ForEach(pets) { pet in
                                    PetCardBannerView(pet: pet, accentColor: petSpotGreen)
                                }
                                
                                // Botão "Adicionar Pet"
                                Button(action: { showAddPetSheet = true }) {
                                    VStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(petSpotGreen.opacity(0.15))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .bold()
                                                .foregroundColor(petSpotGreen)
                                        }
                                        
                                        Text("+ Adicionar\nPet")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(petSpotGreen)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 130, height: 230)
                                    .background(Color(red: 0.94, green: 0.98, blue: 0.96))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(petSpotGreen.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 5. LEMBRETES DE HOJE
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Lembretes de Hoje")
                                .font(.title3)
                                .bold()
                            
                            Spacer()
                            
                            Text("\(completedRemindersCount) de \(todayReminders.count) feitos")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if todayReminders.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Sem lembretes para hoje!")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 20)
                                Spacer()
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(todayReminders) { reminder in
                                    ReminderRowView(reminder: reminder, accentColor: petSpotGreen)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddPetSheet) {
                AddPetView()
            }
        }
    }
}

// MARK: - Cartão do Pet no Carrossel (Banner Style)
struct PetCardBannerView: View {
    let pet: Pet
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Imagem de Capa do Pet com Badge da Próxima Vacina
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "dog.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                            .foregroundColor(.gray.opacity(0.5))
                    )
                
                // Badge de Alerta de Vacina
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.caption2)
                    
                    if let vaccineDate = pet.nextVaccineDate {
                        Text("Próxima vacina: \(vaccineDate.formatted(.dateTime.day().month(.abbreviated)))")
                            .font(.system(size: 11, weight: .semibold))
                    } else {
                        Text("Próxima vacina: 12 Out")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.92))
                .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.15))
                .cornerRadius(12)
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Informação do Animal
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pet.name)
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Text(pet.ageString)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Text(pet.breed)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .frame(width: 220, height: 230)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Botão de Ação Rápida
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 65, height: 65)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Linha de Lembrete Interativo
struct ReminderRowView: View {
    let reminder: Reminder
    let accentColor: Color
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 14) {
            // Checkbox
            Button(action: {
                withAnimation {
                    reminder.isCompleted.toggle()
                    try? modelContext.save()
                }
            }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(reminder.isCompleted ? accentColor : .gray.opacity(0.4))
            }
            
            // Texto do Lembrete
            Text("\(reminder.date.formatted(date: .omitted, time: .shortened)) - \(reminder.title)")
                .font(.system(size: 14, weight: .medium))
                .strikethrough(reminder.isCompleted, color: .gray)
                .foregroundColor(reminder.isCompleted ? .gray : .primary)
            
            Spacer()
            
            // Ícone da Categoria
            Image(systemName: categoryIcon(for: reminder.category))
                .font(.system(size: 16))
                .foregroundColor(accentColor.opacity(0.8))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "vacina", "consulta": return "cross.vial.fill"
        case "medicação", "remédio": return "pill.fill"
        case "passeio": return "figure.walk"
        default: return "pawprint.fill"
        }
    }
}
