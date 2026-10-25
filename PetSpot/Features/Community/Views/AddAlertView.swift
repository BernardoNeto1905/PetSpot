//
//  AddAlertView.swift
//  PetSpot
//
//  Created by Calvin Calvo on 25/10/2026.
//


import SwiftUI

// MARK: - Modelo de dados do alerta

struct LostPetAlert: Identifiable {
    let id = UUID()
    let petName: String
    let petType: String
    let description: String
    let location: String
    let lastSeenDate: Date
    let contact: String
}

// MARK: - AddAlertView

struct AddAlertView: View {

    // MARK: - Propriedades

    @Environment(\.dismiss) private var dismiss

    let onSave: (LostPetAlert) -> Void

    // MARK: - Estado do formulário

    @State private var petName = ""
    @State private var petType = "Cão"
    @State private var description = ""
    @State private var location = ""
    @State private var lastSeenDate = Date()
    @State private var contact = ""

    @State private var showingValidationError = false

    private let petTypes = ["Cão", "Gato", "Outro"]

    private let petSpotGreen = Color(
        red: 0.0,
        green: 0.65,
        blue: 0.45
    )

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    headerSection

                    petInformationSection

                    locationSection

                    contactSection

                    saveButton
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Novo alerta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundStyle(petSpotGreen)
                }
            }
            .alert(
                "Campos obrigatórios",
                isPresented: $showingValidationError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "Preenche o nome do animal, a localização, a descrição e o contacto antes de publicar."
                )
            }
        }
    }

    // MARK: - Cabeçalho

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Animal perdido?")
                        .font(.title2.bold())

                    Text("Ajuda a comunidade a encontrá-lo.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(
                "Partilha informações que ajudem outras pessoas a identificar o animal e a contactar-te."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Informações do animal

    private var petInformationSection: some View {
        VStack(alignment: .leading, spacing: 18) {

            sectionTitle(
                "Informações do animal",
                icon: "pawprint.fill"
            )

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Nome do animal *")

                TextField("Ex.: Bobi", text: $petName)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Tipo de animal *")

                Picker("Tipo de animal", selection: $petType) {
                    ForEach(petTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Descrição e características *")

                TextField(
                    "Raça, cor, tamanho, coleira ou outras características...",
                    text: $description,
                    axis: .vertical
                )
                .lineLimit(4...7)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Localização

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 18) {

            sectionTitle(
                "Último avistamento",
                icon: "mappin.and.ellipse"
            )

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Localização *")

                TextField(
                    "Ex.: Parque da Paz, Almada",
                    text: $location
                )
                .textContentType(.fullStreetAddress)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Data e hora")

                DatePicker(
                    "Última vez visto",
                    selection: $lastSeenDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .tint(petSpotGreen)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Contacto

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 18) {

            sectionTitle(
                "Contacto",
                icon: "phone.fill"
            )

            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("Contacto para ajudar *")

                TextField(
                    "Email ou número de telefone",
                    text: $contact
                )
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Label(
                "Partilha apenas os dados de contacto que pretendes tornar acessíveis a outras pessoas.",
                systemImage: "info.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Color.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Botão de publicação

    private var saveButton: some View {
        Button(action: saveAlert) {
            HStack(spacing: 10) {
                Image(systemName: "megaphone.fill")

                Text("Publicar alerta")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(petSpotGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    // MARK: - Componentes auxiliares

    private func sectionTitle(
        _ title: String,
        icon: String
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(petSpotGreen)

            Text(title)
                .font(.headline)
        }
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
    }

    // MARK: - Guardar alerta

    private func saveAlert() {
        let trimmedName = petName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedLocation = location.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedContact = contact.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard
            !trimmedName.isEmpty,
            !trimmedDescription.isEmpty,
            !trimmedLocation.isEmpty,
            !trimmedContact.isEmpty
        else {
            showingValidationError = true
            return
        }

        let alert = LostPetAlert(
            petName: trimmedName,
            petType: petType,
            description: trimmedDescription,
            location: trimmedLocation,
            lastSeenDate: lastSeenDate,
            contact: trimmedContact
        )

        onSave(alert)
        dismiss()
    }
}
