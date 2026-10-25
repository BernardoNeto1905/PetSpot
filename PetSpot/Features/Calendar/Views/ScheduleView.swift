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
    @State private var errorMessage: String?
    @State private var isLoading = false

    // MARK: - Interface

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && reminders.isEmpty {
                    ProgressView("A carregar agenda...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if reminders.isEmpty {
                    ContentUnavailableView(
                        "Sem Lembretes",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text(
                            "Adiciona vacinas, consultas ou tarefas para o teu pet."
                        )
                    )
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            HStack(alignment: .top, spacing: 12) {

                                // Concluir ou reabrir lembrete
                                Button {
                                    Task {
                                        await toggleReminder(reminder)
                                    }
                                } label: {
                                    Image(
                                        systemName: reminder.isCompleted
                                            ? "checkmark.circle.fill"
                                            : "circle"
                                    )
                                    .font(.title2)
                                    .foregroundColor(
                                        reminder.isCompleted ? .green : .gray
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isLoading)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reminder.title)
                                        .font(.headline)
                                        .strikethrough(
                                            reminder.isCompleted,
                                            color: .gray
                                        )
                                        .foregroundColor(
                                            reminder.isCompleted
                                                ? .gray
                                                : .primary
                                        )

                                    if let petID = reminder.petID,
                                       let pet = pets.first(
                                           where: { $0.id == petID }
                                       ) {
                                        Text("Pet: \(pet.name)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }

                                    Text(
                                        reminder.date,
                                        format: .dateTime
                                            .day()
                                            .month()
                                            .year()
                                            .hour()
                                            .minute()
                                    )
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                    if !reminder.notes.isEmpty {
                                        Text(reminder.notes)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }

                                Spacer(minLength: 8)

                                Text(reminder.category)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Color.orange.opacity(0.2)
                                    )
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteReminders)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Label(
                            "Adicionar Lembrete",
                            systemImage: "plus"
                        )
                    }
                }
            }
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
            .sheet(
                isPresented: $showingAddReminder,
                onDismiss: {
                    Task {
                        await loadData()
                    }
                }
            ) {
                AddReminderView(pets: pets)
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

    // MARK: - Carregar dados do Firebase

    @MainActor
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let fetchedReminders = ReminderService.fetchReminders()
            async let fetchedPets = PetService.fetchPets()

            let loadedReminders = try await fetchedReminders
            let loadedPets = try await fetchedPets

            reminders = loadedReminders.sorted {
                $0.date < $1.date
            }

            pets = loadedPets
            errorMessage = nil

        } catch {
            errorMessage =
                "Não foi possível carregar a agenda: \(error.localizedDescription)"
        }
    }

    // MARK: - Concluir ou reabrir lembrete

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
            errorMessage =
                "Não foi possível atualizar o lembrete: \(error.localizedDescription)"
        }
    }

    // MARK: - Eliminar lembretes do Firebase

    @MainActor
    private func deleteReminders(offsets: IndexSet) {
        let ids = offsets.map { reminders[$0].id }

        Task {
            for id in ids {
                do {
                    try await ReminderService.deleteReminder(id: id)

                    withAnimation {
                        reminders.removeAll {
                            $0.id == id
                        }
                    }

                } catch {
                    errorMessage =
                        "Não foi possível eliminar o lembrete: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Subview para Adicionar Lembrete

struct AddReminderView: View {

    @Environment(\.dismiss) private var dismiss

    let pets: [Pet]

    @State private var title = ""
    @State private var date = Date()
    @State private var category = "Vacina"
    @State private var notes = ""
    @State private var selectedPetID: String?

    @State private var syncWithiOSReminders = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    @StateObject private var reminderManager = ReminderManager()

    private let categories = [
        "Vacina",
        "Consulta",
        "Desparasitação",
        "Outro"
    ]

    // MARK: - Interface

    var body: some View {
        NavigationStack {
            Form {
                Section("Detalhes do Lembrete") {
                    TextField(
                        "Título (ex: Vacina da Raiva)",
                        text: $title
                    )

                    DatePicker(
                        "Data e Hora",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )

                    Picker("Categoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Section("Associar a Animal") {
                    Picker("Pet", selection: $selectedPetID) {
                        Text("Nenhum / Geral")
                            .tag(String?.none)

                        ForEach(pets) { pet in
                            Text(pet.name)
                                .tag(Optional(pet.id))
                        }
                    }
                }

                Section("Notas") {
                    TextField(
                        "Notas adicionais",
                        text: $notes,
                        axis: .vertical
                    )
                }

                Section {
                    Toggle(isOn: $syncWithiOSReminders) {
                        Label(
                            "Adicionar à app Lembretes do iOS",
                            systemImage: "list.bullet.rectangle.portrait.fill"
                        )
                        .foregroundColor(.blue)
                    }

                    Text(
                        "Esta opção também tenta criar um lembrete na app Lembretes do iOS."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                if isSaving {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("A guardar lembrete...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Novo Lembrete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task {
                            await saveReminder()
                        }
                    }
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || isSaving
                    )
                }
            }
            .alert(
                "Erro ao guardar",
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

    // MARK: - Guardar no Firebase

    @MainActor
    private func saveReminder() async {
        let trimmedTitle = title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedTitle.isEmpty else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            // Primeiro, guardar o lembrete no Firebase.
            _ = try await ReminderService.addReminder(
                title: trimmedTitle,
                date: date,
                notes: notes,
                category: category,
                petID: selectedPetID,
                syncWithiOSReminders: syncWithiOSReminders
            )

            // Sincronização opcional com a app Lembretes do iOS.
            if syncWithiOSReminders {
                let petName = pets.first {
                    $0.id == selectedPetID
                }?.name

                let prefix = petName.map { "[\($0)] " } ?? ""
                let fullTitle = "\(prefix)[\(category)] \(trimmedTitle)"

                reminderManager.addReminder(
                    title: fullTitle,
                    dueDate: date,
                    notes: notes
                ) { _ in
                    dismiss()
                }
            } else {
                dismiss()
            }

        } catch {
            errorMessage =
                "Não foi possível guardar o lembrete: \(error.localizedDescription)"
        }
    }
}
