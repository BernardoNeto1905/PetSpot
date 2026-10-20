//
//  ScheduleView.swift
//  PetSpot
//
//  Created by Bernardo on 16/10/2026.
//

import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Buscar todos os lembretes ordenados por data
    @Query(sort: \Reminder.date, order: .forward) private var reminders: [Reminder]
    
    // Buscar também os pets para o seletor na criação de lembretes
    @Query private var pets: [Pet]
    
    @State private var showingAddReminder = false

    var body: some View {
        NavigationStack {
            Group {
                if reminders.isEmpty {
                    ContentUnavailableView(
                        "Sem Lembretes",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Adiciona vacinas, consultas ou tarefas para o teu pet.")
                    )
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            HStack(alignment: .top, spacing: 12) {
                                // Botão de concluir/desconcluir
                                Button {
                                    reminder.isCompleted.toggle()
                                } label: {
                                    Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(reminder.isCompleted ? .green : .gray)
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reminder.title)
                                        .font(.headline)
                                        .strikethrough(reminder.isCompleted, color: .gray)
                                        .foregroundColor(reminder.isCompleted ? .gray : .primary)
                                    
                                    if let petName = reminder.pet?.name {
                                        Text("Pet: \(petName)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text(reminder.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(reminder.category)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteReminders)
                    }
                }
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReminder.toggle() }) {
                        Label("Adicionar Lembrete", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(pets: pets)
            }
        }
    }

    private func deleteReminders(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(reminders[index])
            }
        }
    }
}

// MARK: - Subview para Adicionar Lembrete
struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var pets: [Pet]
    
    @State private var title = ""
    @State private var date = Date()
    @State private var category = "Vacina"
    @State private var notes = ""
    @State private var selectedPet: Pet?
    
    // Estado para a integração com os Lembretes do iOS
    @State private var syncWithiOSReminders = false
    @StateObject private var reminderManager = ReminderManager()
    
    let categories = ["Vacina", "Consulta", "Desparasitação", "Outro"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Detalhes do Lembrete")) {
                    TextField("Título (ex: Vacina da Raiva)", text: $title)
                    DatePicker("Data e Hora", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Categoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Associar a Animal")) {
                    Picker("Pet", selection: $selectedPet) {
                        Text("Nenhum / Geral").tag(Optional<Pet>.none)
                        ForEach(pets) { pet in
                            Text(pet.name).tag(Optional(pet))
                        }
                    }
                }
                
                Section(header: Text("Notas")) {
                    TextField("Notas adicionais", text: $notes, axis: .vertical)
                }
                
                // Nova secção para ativar a sincronização com o iOS Reminders
                Section {
                    Toggle(isOn: $syncWithiOSReminders) {
                        Label("Adicionar à app Lembretes do iOS", systemImage: "list.bullet.rectangle.portrait.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Novo Lembrete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveReminder()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func saveReminder() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else{return}

        let newReminder = Reminder(
            title: title,
            date: date,
            notes: notes,
            category: category,
            syncWithiOSReminders: syncWithiOSReminders,
            pet: selectedPet
        )
        
        // 1. Inserir e Forçar o Save no SwiftData
        modelContext.insert(newReminder)
        try? modelContext.save()
        
        // 2. Se ativado, sincronizar com o EventKit
        if syncWithiOSReminders {
            let petPrefix = selectedPet != nil ? "[\(selectedPet!.name)] " : ""
            let fullTitle = "\(petPrefix)[\(category)] \(title)"
            
            reminderManager.addReminder(title: fullTitle, dueDate: date, notes: notes) { identifier in
                DispatchQueue.main.async {
                    if let identifier = identifier {
                        newReminder.iosReminderIdentifier = identifier
                        try? modelContext.save()
                    }
                    dismiss()
                }
            }
        } else {
            dismiss()
        }
    }
}
