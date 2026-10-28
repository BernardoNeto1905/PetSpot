//
//  AddPetView.swift
//  PetSpot
//
//  Created by Bernardo on 11/10/2026.
//

import SwiftUI

struct AddPetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false

    // nil = adicionar; pet existente = editar
    private let pet: Pet?

    @State private var name: String
    @State private var species: String
    @State private var breed: String
    @State private var birthDate: Date
    @State private var gender: String
    @State private var microchipNumber: String
    @State private var hasVaccineDate: Bool
    @State private var nextVaccineDate: Date
    @State private var medicationNotes: String

    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let speciesOptions = ["Cão", "Gato", "Outro"]
    private let genderOptions = ["Macho", "Fêmea", "Não sei"]

    init(pet: Pet? = nil) {
        self.pet = pet

        _name = State(initialValue: pet?.name ?? "")
        _species = State(initialValue: pet?.species ?? "Cão")
        _breed = State(initialValue: pet?.breed ?? "")
        _birthDate = State(initialValue: pet?.birthDate ?? Date())
        _gender = State(initialValue: pet?.gender ?? "Macho")
        _microchipNumber = State(
            initialValue: pet?.microchipNumber ?? ""
        )
        _hasVaccineDate = State(
            initialValue: pet?.nextVaccineDate != nil
        )
        _nextVaccineDate = State(
            initialValue: pet?.nextVaccineDate ?? Date()
        )
        _medicationNotes = State(
            initialValue: pet?.medicationNotes ?? ""
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Cabeçalho
                    VStack(alignment: .leading, spacing: 4) {
                        Text(
                            pet == nil
                                ? "Adicionar novo pet"
                                : "Editar animal"
                        )
                        .font(.system(size: 28, weight: .bold))

                        Text("Um novo companheiro, todos os cuidados.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Fotografia ilustrativa
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 60, height: 60)

                            Image(systemName: "pawprint.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Adicionar fotografia")
                                .font(.headline)

                            Text("Opcional • Podes fazê-lo mais tarde")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "camera.fill")
                            .foregroundColor(.green)
                            .padding(10)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Campos
                    VStack(alignment: .leading, spacing: 16) {

                        // Nome
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nome do pet")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextField("Ex.: Milo", text: $name)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            Color(.systemGray4),
                                            lineWidth: 1
                                        )
                                )
                        }

                        // Espécie
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Espécie")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 10) {
                                ForEach(speciesOptions, id: \.self) { item in
                                    Button {
                                        species = item
                                    } label: {
                                        HStack {
                                            Image(
                                                systemName:
                                                    item == "Cão"
                                                    ? "dog.fill"
                                                    : item == "Gato"
                                                    ? "cat.fill"
                                                    : "pawprint.fill"
                                            )
                                            Text(item)
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            species == item
                                                ? Color.green.opacity(0.15)
                                                : Color(.systemBackground)
                                        )
                                        .foregroundColor(
                                            species == item
                                                ? .green
                                                : .primary
                                        )
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(
                                                    species == item
                                                        ? Color.green
                                                        : Color(.systemGray4),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                }
                            }
                        }

                        // Raça
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Raça")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextField("Selecionar raça", text: $breed)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            Color(.systemGray4),
                                            lineWidth: 1
                                        )
                                )
                        }

                        // Data de nascimento
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data de nascimento")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            DatePicker(
                                "",
                                selection: $birthDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        }

                        // Sexo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sexo")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            HStack(spacing: 10) {
                                ForEach(genderOptions, id: \.self) { item in
                                    Button {
                                        gender = item
                                    } label: {
                                        Text(item)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                gender == item
                                                    ? Color.green.opacity(0.15)
                                                    : Color(.systemBackground)
                                            )
                                            .foregroundColor(
                                                gender == item
                                                    ? .green
                                                    : .primary
                                            )
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        gender == item
                                                            ? Color.green
                                                            : Color(.systemGray4),
                                                        lineWidth: 1
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Microchip
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Número do microchip")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Spacer()

                                Text("Opcional")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            TextField(
                                "Introduzir os 15 dígitos",
                                text: $microchipNumber
                            )
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color(.systemGray4),
                                        lineWidth: 1
                                    )
                            )

                            Text("Encontras este número no boletim de saúde.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        // Data da próxima vacina
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(
                                "Próxima vacina",
                                isOn: $hasVaccineDate
                            )
                            .tint(.green)

                            if hasVaccineDate {
                                DatePicker(
                                    "Data da vacina",
                                    selection: $nextVaccineDate,
                                    displayedComponents: .date
                                )
                            }
                        }

                        // Medicação e alergias
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notas de medicação ou alergias")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextField(
                                "Notas adicionais",
                                text: $medicationNotes,
                                axis: .vertical
                            )
                            .lineLimit(3...5)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color(.systemGray4),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Guardar
                    VStack(spacing: 8) {
                        Button {
                            Task {
                                await savePet()
                            }
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(
                                        pet == nil
                                            ? "+ Adicionar pet"
                                            : "Guardar alterações"
                                    )
                                    .font(.headline)
                                    .bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(
                            name.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty || isSaving
                        )
                        
                        if let pet = pet {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Apagar animal")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.red)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(14)
                            }
                            .disabled(isSaving || isDeleting)
                        }

                        Text(
                            pet == nil
                                ? "Podes editar estes dados mais tarde."
                                : "As alterações serão guardadas no teu animal."
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.green)
                    .disabled(isSaving)
                }
            }
            .alert(
                pet == nil
                    ? "Erro ao guardar pet"
                    : "Erro ao editar animal",
                isPresented: $showError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            
            .alert(
                "Apagar animal",
                isPresented: $showDeleteConfirmation
            ) {
                Button("Apagar animal", role: .destructive) {
                    Task {
                        await deletePet()
                    }
                }

                Button("Cancelar", role: .cancel) {}
            } message: {
                Text(
                    "Tens a certeza de que queres apagar este animal? " +
                    "Esta ação não pode ser anulada."
                )
            }
        }
    }

    @MainActor
    private func savePet() async {
        isSaving = true
        defer { isSaving = false }

        do {
            let cleanName = name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            let cleanBreed = breed.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            let cleanMicrochip = microchipNumber.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            let cleanNotes = medicationNotes.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            if var existingPet = pet {
                // Atualizar o animal existente
                existingPet.name = cleanName
                existingPet.species = species
                existingPet.breed = cleanBreed
                existingPet.birthDate = birthDate
                existingPet.gender = gender
                existingPet.microchipNumber = cleanMicrochip
                existingPet.nextVaccineDate =
                    hasVaccineDate ? nextVaccineDate : nil
                existingPet.medicationNotes =
                    cleanNotes.isEmpty ? nil : cleanNotes

                try await PetService.updatePet(existingPet)
            } else {
                // Criar um novo animal
                _ = try await PetService.addPet(
                    name: cleanName,
                    species: species,
                    breed: cleanBreed,
                    birthDate: birthDate,
                    gender: gender,
                    microchipNumber: cleanMicrochip,
                    nextVaccineDate:
                        hasVaccineDate ? nextVaccineDate : nil,
                    medicationNotes:
                        cleanNotes.isEmpty ? nil : cleanNotes
                )
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    
    @MainActor
    private func deletePet() async {
        guard let existingPet = pet else { return }

        isDeleting = true
        defer { isDeleting = false }

        do {
            try await PetService.deletePet(existingPet)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
