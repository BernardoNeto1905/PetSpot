//
//  PetListView.swift
//  PetSpot
//
//  Created by Bernardo on 21/10/2026.
//

import SwiftUI

struct PetListView: View {

    // MARK: - Estado

    @State private var pets: [Pet] = []
    @State private var reminders: [Reminder] = []

    @State private var isLoadingPets = false
    @State private var errorMessage: String?

    @State private var showAddPetSheet = false

    @AppStorage("currentUserName")
    private var userName: String = "Utilizador"

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.68,
        blue: 0.42
    )

    // MARK: - Lembretes de Hoje

    private var todayReminders: [Reminder] {
        reminders
            .filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }

    private var completedRemindersCount: Int {
        todayReminders.filter { $0.isCompleted }.count
    }

    private var currentUserDisplayName: String {
        userName
    }

    // MARK: - Carregar dados do Firebase

    @MainActor
    private func loadData() async {
        isLoadingPets = true
        defer { isLoadingPets = false }

        do {
            async let fetchedPets = PetService.fetchPets()
            async let fetchedReminders = ReminderService.fetchReminders()

            let loadedPets = try await fetchedPets
            let loadedReminders = try await fetchedReminders

            pets = loadedPets
            reminders = loadedReminders
                .sorted { $0.date < $1.date }

            errorMessage = nil
        } catch {
            errorMessage = """
            Não foi possível carregar os dados.
            \(error.localizedDescription)
            """
        }
    }

    // MARK: - Concluir lembrete

    @MainActor
    private func toggleReminder(_ reminder: Reminder) async {
        let newValue = !reminder.isCompleted

        do {
            try await ReminderService.setCompleted(
                reminderID: reminder.id,
                isCompleted: newValue
            )

            if let index = reminders.firstIndex(
                where: { $0.id == reminder.id }
            ) {
                reminders[index].isCompleted = newValue
            }

            errorMessage = nil
        } catch {
            errorMessage = """
            Não foi possível atualizar o lembrete.
            \(error.localizedDescription)
            """
        }
    }

    // MARK: - Interface

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    // Cabeçalho
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
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 20))
                                    .padding(8)
                                    .background(
                                        Color(.secondarySystemBackground)
                                    )
                                    .clipShape(Circle())

                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -2, y: 2)
                            }

                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 38, height: 38)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Saudação
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

                    // Os meus pets
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Os meus pets")
                                .font(.title3)
                                .bold()

                            Spacer()

                            Text(
                                "\(pets.count) companheiro\(pets.count == 1 ? "" : "s")"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        ScrollView(
                            .horizontal,
                            showsIndicators: false
                        ) {
                            HStack(spacing: 16) {
                                ForEach(pets) { pet in
                                    NavigationLink {
                                        PetDetailView(pet: pet)
                                    } label: {
                                        PetCardBannerView(
                                            pet: pet,
                                            accentColor: petSpotGreen
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                                addPetButton
                            }
                            .padding(.horizontal)
                        }

                        if isLoadingPets && pets.isEmpty {
                            HStack {
                                Spacer()
                                ProgressView("A carregar animais...")
                                Spacer()
                            }
                            .padding(.vertical, 12)
                        }

                        if let error = errorMessage {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.red)

                                Button("Tentar novamente") {
                                    Task {
                                        await loadData()
                                    }
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(petSpotGreen)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Lembretes de Hoje
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Lembretes de Hoje")
                                .font(.title3)
                                .bold()

                            Spacer()

                            Text(
                                "\(completedRemindersCount) de \(todayReminders.count) feitos"
                            )
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

                                    Text(
                                        isLoadingPets
                                            ? "A carregar lembretes..."
                                            : "Sem lembretes para hoje!"
                                    )
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 20)

                                Spacer()
                            }
                            .background(
                                Color(.secondarySystemBackground)
                            )
                            .cornerRadius(16)

                        } else {
                            VStack(spacing: 10) {
                                ForEach(todayReminders) { reminder in
                                    ReminderRowView(
                                        reminder: reminder,
                                        accentColor: petSpotGreen
                                    ) {
                                        Task {
                                            await toggleReminder(reminder)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
            .sheet(
                isPresented: $showAddPetSheet,
                onDismiss: {
                    Task {
                        await loadData()
                    }
                }
            ) {
                AddPetView()
            }
            .alert(
                "Erro",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: {
                        if !$0 {
                            errorMessage = nil
                        }
                    }
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

    // MARK: - Botão Adicionar Pet

    private var addPetButton: some View {
        Button {
            showAddPetSheet = true
        } label: {
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
            .background(
                Color(red: 0.94, green: 0.98, blue: 0.96)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        petSpotGreen.opacity(0.3),
                        style: StrokeStyle(
                            lineWidth: 1.5,
                            dash: [6]
                        )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Cartão do Pet no Carrossel

struct PetCardBannerView: View {

    let pet: Pet
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

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

                HStack(spacing: 6) {
                    Image(systemName: "syringe")
                        .font(.caption2)

                    if let vaccineDate = pet.nextVaccineDate {
                        Text(
                            "Próxima vacina: \(vaccineDate.formatted(.dateTime.day().month(.abbreviated)))"
                        )
                        .font(.system(size: 11, weight: .semibold))
                    } else {
                        Text("Sem vacina agendada")
                            .font(.system(size: 11, weight: .semibold))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.92))
                .foregroundColor(
                    Color(red: 0.65, green: 0.45, blue: 0.15)
                )
                .cornerRadius(12)
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pet.name)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)

                    Spacer()

                    Text(pet.ageString)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Text(
                    pet.breed.isEmpty ? "Raça não indicada" : pet.breed
                )
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            .padding(12)
        }
        .frame(width: 220, height: 230)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(
            color: .black.opacity(0.06),
            radius: 8,
            x: 0,
            y: 4
        )
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
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            Button(action: onToggle) {
                Image(
                    systemName: reminder.isCompleted
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 22))
                .foregroundColor(
                    reminder.isCompleted
                        ? accentColor
                        : .gray.opacity(0.4)
                )
            }
            .buttonStyle(.plain)

            Text(
                "\(reminder.date.formatted(date: .omitted, time: .shortened)) - \(reminder.title)"
            )
            .font(.system(size: 14, weight: .medium))
            .strikethrough(reminder.isCompleted, color: .gray)
            .foregroundColor(
                reminder.isCompleted ? .gray : .primary
            )

            Spacer()

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
        case "vacina", "consulta":
            return "cross.vial.fill"
        case "medicação", "remédio":
            return "pill.fill"
        case "passeio":
            return "figure.walk"
        default:
            return "pawprint.fill"
        }
    }
}
