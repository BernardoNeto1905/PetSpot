//
//  AddReminderView.swift
//  PetSpot
//
//  Created by Bernardo on 27/10/2026.
//

import SwiftUI

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

                        // CARTÃO 1: Informações Principais
                        VStack(alignment: .leading, spacing: 16) {
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
                            DatePicker(selection: $date, displayedComponents: [.date]) {
                                Label {
                                    Text("Data").font(.body)
                                } icon: {
                                    Image(systemName: "calendar").foregroundColor(primaryGreen)
                                }
                            }
                            .padding(14)

                            Divider().padding(.leading, 40)

                            DatePicker(selection: $date, displayedComponents: [.hourAndMinute]) {
                                Label {
                                    Text("Hora").font(.body)
                                } icon: {
                                    Image(systemName: "clock").foregroundColor(primaryGreen)
                                }
                            }
                            .padding(14)

                            Divider().padding(.leading, 40)

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
                        
                        Toggle(isOn: $syncWithiOSReminders) {
                            Text("Adicionar à app Lembretes do iOS")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)

                        Spacer().frame(height: 80)
                    }
                    .padding(16)
                }

                // Botão inferior fixo
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
