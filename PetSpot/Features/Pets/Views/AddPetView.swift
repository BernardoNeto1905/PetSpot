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
    @State private var species = "Cão"
    @State private var breed = ""
    @State private var birthDate = Date()
    @State private var gender = "Macho"
    @State private var microchipNumber = ""
    @State private var hasVaccineDate = false
    @State private var nextVaccineDate = Date()
    @State private var medicationNotes = ""

    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let speciesOptions = ["Cão", "Gato", "Outro"]
    private let genderOptions = ["Macho", "Fêmea", "Não sei"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Cabeçalho / Título informativo
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Adicionar novo pet")
                            .font(.system(size: 28, weight: .bold))
                        Text("Um novo companheiro, todos os cuidados.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Foto do Pet (Opcional)
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
                                .foregroundColor(.primary)
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

                    // Campos de Formulário em Cartões
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
                                        .stroke(Color(.systemGray4), lineWidth: 1)
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
                                            Image(systemName: item == "Cão" ? "dog.fill" : (item == "Gato" ? "cat.fill" : "pawprint.fill"))
                                            Text(item)
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(species == item ? Color.green.opacity(0.15) : Color(.systemBackground))
                                        .foregroundColor(species == item ? .green : .primary)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(species == item ? Color.green : Color(.systemGray4), lineWidth: 1)
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
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }

                        // Data de Nascimento
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Data de nascimento")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
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
                                            .background(gender == item ? Color.green.opacity(0.15) : Color(.systemBackground))
                                            .foregroundColor(gender == item ? .green : .primary)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(gender == item ? Color.green : Color(.systemGray4), lineWidth: 1)
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
                            TextField("Introduzir os 15 dígitos", text: $microchipNumber)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                            Text("Encontras este número no boletim de saúde.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        // Notas de Medicação
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notas de medicação ou alergias")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField("Notas adicionais", text: $medicationNotes, axis: .vertical)
                                .lineLimit(3...5)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Botão Guardar Principal
                    VStack(spacing: 8) {
                        Button {
                            Task { await savePet() }
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("+ Adicionar pet")
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
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)

                        Text("Podes editar estes dados mais tarde.")
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
            .alert("Erro ao guardar Pet", isPresented: $showError) {
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
            _ = try await PetService.addPet(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                species: species,
                breed: breed.trimmingCharacters(in: .whitespacesAndNewlines),
                birthDate: birthDate,
                gender: gender,
                microchipNumber: microchipNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                nextVaccineDate: hasVaccineDate ? nextVaccineDate : nil,
                medicationNotes: medicationNotes.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
