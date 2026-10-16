//
//  AddPetView.swift
//  PetSpot
//
//  Created by Bernardo on 11/10/2026.
//

import SwiftUI
import SwiftData

struct AddPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var microchipNumber = ""
    @State private var hasVaccineDate = false
    @State private var nextVaccineDate = Date()
    @State private var medicationNotes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações Básicas") {
                    TextField("Nome do Pet", text: $name)
                    TextField("Raça", text: $breed)
                    DatePicker("Data de Nascimento", selection: $birthDate, displayedComponents: .date)
                }
                
                Section("Identificação & Saúde") {
                    TextField("Número do Microchip", text: $microchipNumber)
                    
                    Toggle("Tem vacina agendada?", isOn: $hasVaccineDate)
                    
                    if hasVaccineDate {
                        DatePicker("Próxima Vacina", selection: $nextVaccineDate, displayedComponents: .date)
                    }
                }
                
                Section("Notas & Medicação") {
                    TextField("Notas de medicação ou alergias", text: $medicationNotes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Novo Pet 🐾")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        savePet()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
    
    private func savePet() {
        let newPet = Pet(
            name: name,
            breed: breed,
            birthDate: birthDate,
            microchipNumber: microchipNumber,
            nextVaccineDate: hasVaccineDate ? nextVaccineDate : nil,
            medicationNotes: medicationNotes.isEmpty ? nil : medicationNotes
        )
        
        modelContext.insert(newPet)
        try? modelContext.save()
        dismiss()
    }
}
