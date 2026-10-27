//
//  ScheduleView.swift
//  PetSpot
//
//  Created by Bernardo on 16/10/2026.
//

import SwiftUI

struct ScheduleView: View {

    // MARK: - Estado
    @State private var showingAddReminder = false
    @State private var reminders: [Reminder] = []
    @State private var pets: [Pet] = []
    @State private var selectedPetID: String? = nil // nil = Todos os Pets
    @State private var selectedDate: Date = Date()
    @State private var errorMessage: String?
    @State private var isLoading = false

    // Paleta de cores da app
    private let primaryGreen = Color(red: 0.0, green: 0.68, blue: 0.45)
    private let backgroundColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    // MARK: - Interface Principais
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Cabeçalho personalizado com "Agenda" e o botão de calendário ao lado
                        HStack(alignment: .center) {
                            Text("Agenda")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                                                    
                            Spacer()
                                                    
                            Button {
                                // Ação do botão do calendário no topo
                            } label: {
                                Image(systemName: "calendar")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // 1. Calendário Mensal
                        CalendarHeaderView(
                            selectedDate: $selectedDate,
                            reminders: reminders,
                            primaryColor: primaryGreen
                        )
                        .padding(.horizontal)

                        // 2. Filtro de Pets (Cápsulas)
                        PetFilterBar(
                            pets: pets,
                            selectedPetID: $selectedPetID,
                            primaryColor: primaryGreen
                        )

                        // 3. Lista de Lembretes Agrupados
                        if isLoading && reminders.isEmpty {
                            ProgressView("A carregar agenda...")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                        } else if filteredReminders.isEmpty {
                            ContentUnavailableView(
                                "Sem Lembretes",
                                systemImage: "calendar.badge.exclamationmark",
                                description: Text("Não há tarefas registadas para este filtro.")
                            )
                            .padding(.top, 20)
                        } else {
                            ReminderSectionsView(
                                reminders: filteredReminders,
                                pets: pets,
                                onToggle: { reminder in
                                    Task { await toggleReminder(reminder) }
                                }
                            )
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 80) // Espaço para o botão flutuante
                }

                // 4. Botão Flutuante (+)
                Button {
                    showingAddReminder = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(primaryGreen)
                        .clipShape(Circle())
                        .shadow(color: primaryGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            
            .navigationBarHidden(true)
            .task { await loadData() }
            .refreshable { await loadData() }
            .sheet(isPresented: $showingAddReminder, onDismiss: {
                Task { await loadData() }
            }) {
                AddReminderView(pets: pets)
            }
            .alert("Erro", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // Lembretes filtrados por Pet selecionado
    private var filteredReminders: [Reminder] {
        if let selectedPetID {
            return reminders.filter { $0.petID == selectedPetID }
        }
        return reminders
    }

    // MARK: - Métodos de Dados
    @MainActor
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let fetchedReminders = ReminderService.fetchReminders()
            async let fetchedPets = PetService.fetchPets()

            let loadedReminders = try await fetchedReminders
            let loadedPets = try await fetchedPets

            reminders = loadedReminders.sorted { $0.date < $1.date }
            pets = loadedPets
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar a agenda: \(error.localizedDescription)"
        }
    }

    @MainActor
    private func toggleReminder(_ reminder: Reminder) async {
        let newValue = !reminder.isCompleted
        do {
            try await ReminderService.setCompleted(reminderID: reminder.id, isCompleted: newValue)
            if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
                reminders[index].isCompleted = newValue
            }
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível atualizar o lembrete: \(error.localizedDescription)"
        }
    }
}

// MARK: - Componente 1: Vista do Calendário
struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    let reminders: [Reminder]
    let primaryColor: Color

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "T", "Q", "Q", "S", "S", "D"]

    var body: some View {
        VStack(spacing: 16) {
            // Mês e Setas de Navegação
            HStack {
                Text(monthYearString(from: selectedDate))
                    .font(.title3.bold())
                Spacer()
                HStack(spacing: 16) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                    }
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                            .foregroundColor(primaryColor)
                    }
                }
            }

            // Dias da semana
            HStack {
                ForEach(0..<7, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .font(.caption.bold())
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // Grelha de Dias
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasReminders: hasReminders(on: date),
                            primaryColor: primaryColor
                        )
                        .onTapGesture { selectedDate = date }
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // Auxiliares do Calendário
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func hasReminders(on date: Date) -> Bool {
        reminders.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let firstDayOfWeek = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return []
        }

        let weekday = calendar.component(.weekday, from: firstDayOfWeek)
        // Ajuste para segunda-feira ser o primeiro dia (1=Dom, 2=Seg, ...)
        let offsetDays = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        let numberOfDays = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0

        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(date)
            }
        }
        return days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasReminders: Bool
    let primaryColor: Color

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 34, height: 34)
                .background(isSelected ? primaryColor : Color.clear)
                .clipShape(Circle())

            // Ponto indicador de evento
            Circle()
                .fill(hasReminders ? (isSelected ? .orange : primaryColor) : Color.clear)
                .frame(width: 4, height: 4)
        }
    }
}

// MARK: - Componente 2: Barra de Filtro de Pets
struct PetFilterBar: View {
    let pets: [Pet]
    @Binding var selectedPetID: String?
    let primaryColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Opção Todos
                FilterChip(
                    title: "Todos os Pets",
                    isSelected: selectedPetID == nil,
                    primaryColor: primaryColor
                ) {
                    selectedPetID = nil
                }

                // Lista de Pets
                ForEach(pets) { pet in
                    FilterChip(
                        title: pet.name,
                        isSelected: selectedPetID == pet.id,
                        primaryColor: primaryColor
                    ) {
                        selectedPetID = pet.id
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let primaryColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? primaryColor : Color.white)
                .foregroundColor(isSelected ? .white : .gray)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Componente 3: Secções e Cartões de Lembretes
struct ReminderSectionsView: View {
    let reminders: [Reminder]
    let pets: [Pet]
    let onToggle: (Reminder) -> Void

    private var todayReminders: [Reminder] {
        reminders.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var tomorrowReminders: [Reminder] {
        reminders.filter { Calendar.current.isDateInTomorrow($0.date) }
    }

    private var upcomingReminders: [Reminder] {
        reminders.filter {
            !Calendar.current.isDateInToday($0.date) && !Calendar.current.isDateInTomorrow($0.date)
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            if !todayReminders.isEmpty {
                ReminderSectionGroup(
                    title: "Hoje",
                    subtitle: formatDateHeader(Date()),
                    reminders: todayReminders,
                    pets: pets,
                    accentColor: .orange
                )
            }

            if !tomorrowReminders.isEmpty {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                ReminderSectionGroup(
                    title: "Amanhã",
                    subtitle: formatDateHeader(tomorrow),
                    reminders: tomorrowReminders,
                    pets: pets,
                    accentColor: Color(red: 0.0, green: 0.68, blue: 0.45)
                )
            }

            if !upcomingReminders.isEmpty {
                ReminderSectionGroup(
                    title: "Próximos",
                    subtitle: "",
                    reminders: upcomingReminders,
                    pets: pets,
                    accentColor: .blue
                )
            }
        }
        .padding(.horizontal)
    }

    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "d MMM · EEEE"
        return formatter.string(from: date).capitalized
    }
}

struct ReminderSectionGroup: View {
    let title: String
    let subtitle: String
    let reminders: [Reminder]
    let pets: [Pet]
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            ForEach(reminders) { reminder in
                ReminderCardView(
                    reminder: reminder,
                    pet: pets.first(where: { $0.id == reminder.petID }),
                    accentColor: accentColor
                )
            }
        }
    }
}

struct ReminderCardView: View {
    let reminder: Reminder
    let pet: Pet?
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            // Linha lateral de acento
            RoundedRectangle(cornerRadius: 3)
                .fill(accentColor)
                .frame(width: 4)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 6) {
                // Hora e Ícone da Categoria
                HStack(spacing: 6) {
                    Text(reminder.date, format: .dateTime.hour().minute())
                        .font(.headline.bold())

                    Image(systemName: iconForCategory(reminder.category))
                        .font(.caption)
                        .foregroundColor(accentColor)
                }

                // Título do Lembrete
                Text(reminder.title)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)

                // Detalhes do Pet e Notas
                HStack(spacing: 6) {
                    if let pet = pet {
                        // Avatar placeholder do Pet (pode ser substituído por AsyncImage se tiveres foto)
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 18, height: 18)
                            .overlay(
                                Text(String(pet.name.prefix(1)))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )

                        Text(pet.name)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if !reminder.notes.isEmpty {
                        Text("• \(reminder.notes)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "desparasitação", "comprimido": return "pill.fill"
        case "vacina": return "syringe.fill"
        case "consulta": return "stethoscope"
        default: return "bell.fill"
        }
    }
}

// MARK: - Subview para Adicionar Lembrete (Redenhado)
struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss

    let pets: [Pet]

    @State private var title = ""
    @State private var date = Date()
    @State private var category = "Medicação"
    @State private var notes = ""
    @State private var selectedPetID: String?

    @State private var repeatOption = "Nunca"
    @State private var notificationEnabled = true
    @State private var syncWithiOSReminders = false
    
    @State private var isSaving = false
    @State private var errorMessage: String?

    @StateObject private var reminderManager = ReminderManager()

    private let categories = ["Medicação", "Vacina", "Consulta", "Desparasitação", "Outro"]
    private let repeatOptions = ["Nunca", "Todos os dias", "Todas as semanas", "Todos os meses"]
    
    private let primaryGreen = Color(red: 0.0, green: 0.68, blue: 0.45)
    private let backgroundColor = Color(red: 0.96, green: 0.96, blue: 0.98)

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Título e subtítulo do ecrã
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Adicionar lembrete")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Para não te esqueceres de nenhum cuidado.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)

                        // CARTÃO 1: Informações Principais (Título, Pet, Categoria)
                        VStack(alignment: .leading, spacing: 16) {
                            // Título do Lembrete
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Título do lembrete")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                
                                TextField("Ex: Desparasitante interno", text: $title)
                                    .font(.body)
                                    .padding(12)
                                    .background(backgroundColor)
                                    .cornerRadius(12)
                            }

                            Divider()

                            // Seleção de Pet
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Para que pet?")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(pets) { pet in
                                            let isSelected = selectedPetID == pet.id
                                            Button {
                                                selectedPetID = pet.id
                                            } label: {
                                                HStack(spacing: 8) {
                                                    // Avatar circular do Pet
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 28, height: 28)
                                                        .overlay(
                                                            Text(String(pet.name.prefix(1)))
                                                                .font(.caption.bold())
                                                                .foregroundColor(.primary)
                                                        )

                                                    Text(pet.name)
                                                        .font(.subheadline.weight(.medium))
                                                        .foregroundColor(.primary)

                                                    if isSelected {
                                                        Image(systemName: "checkmark")
                                                            .font(.caption.bold())
                                                            .foregroundColor(primaryGreen)
                                                    }
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(isSelected ? primaryGreen.opacity(0.12) : backgroundColor)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(isSelected ? primaryGreen : Color.clear, lineWidth: 1.5)
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }

                            Divider()

                            // Categoria
                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: iconForCategory(category))
                                        .font(.subheadline)
                                        .foregroundColor(primaryGreen)
                                        .frame(width: 32, height: 32)
                                        .background(primaryGreen.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Categoria")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                        
                                        Picker("Categoria", selection: $category) {
                                            ForEach(categories, id: \.self) { cat in
                                                Text(cat).tag(cat)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .labelsHidden()
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)

                        // CARTÃO 2: Agendamento e Notificações
                        VStack(spacing: 0) {
                            // Data
                            DatePicker(selection: $date, displayedComponents: [.date]) {
                                Label {
                                    Text("Data").font(.body)
                                } icon: {
                                    Image(systemName: "calendar").foregroundColor(primaryGreen)
                                }
                            }
                            .padding(14)

                            Divider().padding(.leading, 40)

                            // Hora
                            DatePicker(selection: $date, displayedComponents: [.hourAndMinute]) {
                                Label {
                                    Text("Hora").font(.body)
                                } icon: {
                                    Image(systemName: "clock").foregroundColor(primaryGreen)
                                }
                            }
                            .padding(14)

                            Divider().padding(.leading, 40)

                            // Repetir
                            HStack {
                                Label {
                                    Text("Repetir").font(.body)
                                } icon: {
                                    Image(systemName: "repeat").foregroundColor(primaryGreen)
                                }
                                Spacer()
                                Picker("Repetir", selection: $repeatOption) {
                                    ForEach(repeatOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            .padding(14)

                            Divider().padding(.leading, 40)

                            // Notificação
                            Toggle(isOn: $notificationEnabled) {
                                Label {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Notificação").font(.body)
                                        Text("À hora do lembrete").font(.caption).foregroundColor(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: "bell").foregroundColor(primaryGreen)
                                }
                            }
                            .padding(14)
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)

                        // CARTÃO 3: Notas
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Notas")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Opcional")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            TextField("Ex.: 1 comprimido após a refeição", text: $notes, axis: .vertical)
                                .font(.body)
                                .padding(12)
                                .background(backgroundColor)
                                .cornerRadius(12)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
                        
                        // Sincronização iOS opcional discretamente inserida
                        Toggle(isOn: $syncWithiOSReminders) {
                            Text("Adicionar à app Lembretes do iOS")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)

                        // Espaço inferior para o botão fixo
                        Spacer().frame(height: 80)
                    }
                    .padding(16)
                }

                // Botão inferior fixo "Adicionar lembrete"
                VStack(spacing: 8) {
                    Button {
                        Task { await saveReminder() }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "plus")
                                    .font(.headline.bold())
                                Text("Adicionar lembrete")
                                    .font(.headline.bold())
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.4) : primaryGreen)
                        .clipShape(Capsule())
                        .shadow(color: primaryGreen.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)

                    Text("Podes editar este lembrete mais tarde.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.05), radius: 4)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(primaryGreen)
                    .font(.subheadline.weight(.semibold))
                }
            }
            .alert("Erro ao guardar", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func iconForCategory(_ cat: String) -> String {
        switch cat.lowercased() {
        case "medicação", "desparasitação": return "pill.fill"
        case "vacina": return "syringe.fill"
        case "consulta": return "stethoscope"
        default: return "bell.fill"
        }
    }

    // MARK: - Guardar no Firebase
    @MainActor
    private func saveReminder() async {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await ReminderService.addReminder(
                title: trimmedTitle,
                date: date,
                notes: notes,
                category: category,
                petID: selectedPetID,
                syncWithiOSReminders: syncWithiOSReminders
            )

            if syncWithiOSReminders {
                let petName = pets.first { $0.id == selectedPetID }?.name
                let prefix = petName.map { "[\($0)] " } ?? ""
                let fullTitle = "\(prefix)[\(category)] \(trimmedTitle)"

                reminderManager.addReminder(title: fullTitle, dueDate: date, notes: notes) { _ in
                    dismiss()
                }
            } else {
                dismiss()
            }
        } catch {
            errorMessage = "Não foi possível guardar o lembrete: \(error.localizedDescription)"
        }
    }
}
