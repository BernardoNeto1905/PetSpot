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
            }
            .navigationTitle("Novo Lembrete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let newReminder = Reminder(
                            title: title,
                            date: date,
                            notes: notes,
                            category: category,
                            pet: selectedPet
                        )
                        modelContext.insert(newReminder)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
