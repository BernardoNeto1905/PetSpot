//
//  CommunityView.swift
//  PetSpot
//
//  Created by Bernardo on 16/10/2026.
//

import SwiftUI

// Modelo simples para representar um alerta da comunidade
struct PetAlert: Identifiable {
    let id = UUID()
    let petName: String
    let breed: String
    let location: String
    let date: Date
    let contactInfo: String
    let description: String
    let isLost: Bool // true se for perdido, false se for avistado/encontrado
}

struct CommunityView: View {
    // Dados temporários/mock para simular alertas da comunidade
    @State private var alerts: [PetAlert] = [
        PetAlert(
            petName: "Max",
            breed: "Golden Retriever",
            location: "Parque da Cidade, Leiria",
            date: Date().addingTimeInterval(-3600 * 5),
            contactInfo: "+351 912 345 678",
            description: "Fugiu assustado com o barulho de trovões. Usa coleira azul.",
            isLost: true
        ),
        PetAlert(
            petName: "Luna",
            breed: "Gato Persa",
            location: "Zona Histórica, Leiria",
            date: Date().addingTimeInterval(-3600 * 24),
            contactInfo: "+351 969 876 543",
            description: "Visto perto da Sé, parece faminto mas amigável.",
            isLost: false
        )
    ]
    
    @State private var showingAddAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(alerts) { alert in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            // Etiqueta de Perigo/Estado
                            Text(alert.isLost ? "🔴 Perdido" : "🟢 Avistado")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(alert.isLost ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                                .foregroundColor(alert.isLost ? .red : .green)
                                .cornerRadius(6)
                            
                            Spacer()
                            
                            Text(alert.date, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(alert.petName)
                            .font(.headline)
                        
                        Text("Raça: \(alert.breed)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("📍 \(alert.location)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        
                        Text(alert.description)
                            .font(.body)
                            .padding(.top, 2)
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                            Text(alert.contactInfo)
                                .font(.subheadline)
                                .bold()
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Comunidade & Alertas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAlert.toggle() }) {
                        Label("Novo Alerta", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddAlert) {
                AddAlertView { newAlert in
                    alerts.insert(newAlert, at: 0)
                }
            }
        }
    }
}

// MARK: - Subview para Criar Novo Alerta
struct AddAlertView: View {
    @Environment(\.dismiss) private var dismiss

    var onSave: (PetAlert) -> Void

    @State private var petName = ""
    @State private var breed = ""
    @State private var location = ""
    @State private var contactInfo = ""
    @State private var description = ""
    @State private var isLost = true

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tipo de Alerta")) {
                    Picker("Estado", selection: $isLost) {
                        Text("Animal Perdido").tag(true)
                        Text("Animal Avistado/Encontrado").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Detalhes do Animal")) {
                    TextField("Nome do Animal (ou 'Desconhecido')", text: $petName)
                    TextField("Raça ou Espécie (ex: Cão Raça Mista)", text: $breed)
                    TextField("Localização (ex: Rua Direita, Leiria)", text: $location)
                }

                Section(header: Text("Contacto e Descrição")) {
                    TextField("Telemóvel para contacto", text: $contactInfo)
                        .keyboardType(.phonePad)
                    TextField("Descrição detalhada (ex: roupa, aspeto, coleira)", text: $description, axis: .vertical)
                }
            }
            .navigationTitle("Publicar Alerta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publicar") {
                        let alert = PetAlert(
                            petName: petName.isEmpty ? "Animal Sem Nome" : petName,
                            breed: breed.isEmpty ? "Desconhecida" : breed,
                            location: location.isEmpty ? "Localização não especificada" : location,
                            date: Date(),
                            contactInfo: contactInfo.isEmpty ? "Sem contacto" : contactInfo,
                            description: description,
                            isLost: isLost
                        )
                        onSave(alert)
                        dismiss()
                    }
                    .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}	
