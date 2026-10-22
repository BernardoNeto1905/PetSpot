//
//  AddPetView.swift
//  PetSpot
//
//  Created by Bernardo on 11/10/2026.
//


import SwiftUI

struct AddPetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var microchipNumber = ""
    @State private var hasVaccineDate = false
    @State private var nextVaccineDate = Date()
    @State private var medicationNotes = ""

    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Básicas") {
                    TextField("Nome do Pet", text: $name)
                    TextField("Raça", text: $breed)

                    DatePicker(
                        "Data de Nascimento",
                        selection: $birthDate,
                        displayedComponents: .date
                    )
                }

                Section("Identificação & Saúde") {
                    TextField(
                        "Número do Microchip",
                        text: $microchipNumber
                    )

                    Toggle(
                        "Tem vacina agendada?",
                        isOn: $hasVaccineDate
                    )

                    if hasVaccineDate {
                        DatePicker(
                            "Próxima Vacina",
                            selection: $nextVaccineDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Notas & Medicação") {
                    TextField(
                        "Notas de medicação ou alergias",
                        text: $medicationNotes,
                        axis: .vertical
                    )
                    .lineLimit(3...5)
                }
            }
            .navigationTitle("Novo Pet 🐾")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await savePet()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Guardar")
                        }
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || isSaving
                    )
                }
            }
            .alert(
                "Erro ao guardar Pet",
                isPresented: $showError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    @MainActor
    private func savePet() async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await FirebasePetService.addPet(
                name: name.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                breed: breed,
                birthDate: birthDate,
                microchipNumber: microchipNumber,
                nextVaccineDate: hasVaccineDate
                    ? nextVaccineDate
                    : nil,
                medicationNotes: medicationNotes
            )

            dismiss()

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
